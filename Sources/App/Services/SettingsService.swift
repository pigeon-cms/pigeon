import Vapor

enum Endpoint: String, Codable {
    case json
    case graphQL
}

final class SettingsService: Service {

    /// TODO: thread safety
    var enabledEndpoints: [Endpoint]?
    var defaultPageSize: Int?
    var maxPageSize: Int?

    func setting<T: Codable>(request: Request,
                             _ setting: ReferenceWritableKeyPath<SettingsService, T?>) throws -> Future<T> {
        if let setting = self[keyPath: setting] {
            /// by default, return the in-memory setting
            return request.eventLoop.newSucceededFuture(result: setting)
        } else {
            let cache = try request.make(KeyedCache.self)
            return try self.setting(request: request, setting, from: cache)
        }
    }

    private func setting<T: Codable>(request: Request,
                                     _ setting: ReferenceWritableKeyPath<SettingsService, T?>,
                                     from cache: KeyedCache) throws -> Future<T> {
        return cache.get(try setting.string(), as: T.self).flatMap { cached  in
            guard let cached = cached else {
                return try self.createDefaultSettings(setting, cache)
            }
            return request.eventLoop.newSucceededFuture(result: cached)
        }
    }

    private func createDefaultSettings<T: Codable>(_ setting: ReferenceWritableKeyPath<SettingsService, T?>,
                                                   _ cache: KeyedCache) throws -> Future<T> {
        switch setting {
        case \SettingsService.enabledEndpoints:
            let defaultEndpoints: [Endpoint] = [.json, .graphQL]
            self.enabledEndpoints = defaultEndpoints
            return cache.set(try setting.string(), to: defaultEndpoints as! T).map {
                return defaultEndpoints as! T
            }
        case \SettingsService.defaultPageSize:
            let defaultPageSize = 20
            self.defaultPageSize = defaultPageSize
            return cache.set(try setting.string(), to: defaultPageSize as! T).map {
                return defaultPageSize as! T
            }
        case \SettingsService.maxPageSize:
            let defaultMaxPageSize = 20
            self.maxPageSize = defaultMaxPageSize
            return cache.set(try setting.string(), to: defaultMaxPageSize as! T).map {
                return defaultMaxPageSize as! T
            }
        default: throw Abort(.notFound)
        }
    }

    init(container: Container) {
        print("INIT")
    }

}

private extension ReferenceWritableKeyPath where Root == SettingsService {
    func string() throws -> String {
        switch self {
        case \SettingsService.enabledEndpoints: return "enabledEndpoints"
        case \SettingsService.defaultPageSize: return "defaultPageSize"
        case \SettingsService.maxPageSize: return "maxPageSize"
        default: throw Abort(.notFound)
        }
    }
}

extension Request {

    func enabledEndpoints() throws -> Future<[Endpoint]> {
        return try make(SettingsService.self).setting(request: self, \.enabledEndpoints)
    }

    func defaultPageSize() throws -> Future<Int> {
        return try make(SettingsService.self).setting(request: self, \.defaultPageSize)
    }

    func maxPageSize() throws -> Future<Int> {
        return try make(SettingsService.self).setting(request: self, \.maxPageSize)
    }

}
