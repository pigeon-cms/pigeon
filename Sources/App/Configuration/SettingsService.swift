import Vapor

final class SettingsService: Service {

    /// Honestly a singleton is gross and completely antithetical to Vapor style.
    /// But, this can take >500 requests per second, while a Service could barely take 100.
    /// Until Vapor supports services.singleton, this'll do.
    static var shared = SettingsService()

    /// TODO: thread safety
    fileprivate var settings: Settings?

    private static let cacheKey = "PigeonCMSSettings"

    func get<T: Codable>(setting: WritableKeyPath<Settings, T>,
                         _ request: Request) throws -> Future<T> {
        if let setting = settings?[keyPath: setting] {
            /// by default, return the in-memory setting
            return request.eventLoop.newSucceededFuture(result: setting)
        } else {
            let cache = try request.sharedContainer.make(KeyedCache.self)
            return try self.setting(eventLoop: request.eventLoop, setting, from: cache)
        }
    }

    private func setting<T: Codable>(eventLoop: EventLoop,
                                     _ setting: WritableKeyPath<Settings, T>,
                                     from cache: KeyedCache) throws -> Future<T> {
        return cache.get(SettingsService.cacheKey, as: Settings.self).flatMap { cached in
            guard let cached = cached else {
                return try self.createDefaultSettings(setting, cache)
            }
            self.settings = cached
            return eventLoop.newSucceededFuture(result: cached[keyPath: setting])
        }
    }

    private func createDefaultSettings<T: Codable>(_ setting: WritableKeyPath<Settings, T>,
                                                   _ cache: KeyedCache) throws -> Future<T> {
        let defaults = Settings.defaults
        self.settings = defaults

        return cache.set(SettingsService.cacheKey, to: defaults).map {
            return defaults[keyPath: setting]
        }
    }

    private init() {
        print("INIT")
    }

}

extension Request {

    func enabledEndpoints() throws -> Future<[Endpoint: Bool]> {
        return try SettingsService.shared.get(setting: \.enabledEndpoints, self)
    }

    func defaultPageSize() throws -> Future<Int> {
        return try SettingsService.shared.get(setting: \.defaultPageSize, self)
    }

    func maxPageSize() throws -> Future<Int?> {
        return try SettingsService.shared.get(setting: \.maxPageSize, self)
    }

}
