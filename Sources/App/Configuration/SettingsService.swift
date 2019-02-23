import Vapor

final class SettingsService: Service {

    /// Honestly a singleton is gross and completely antithetical to Vapor style.
    /// But, this can take >500 requests per second, while a Service could barely take 100.
    /// Until Vapor supports services.singleton, this'll do.
    static var shared = SettingsService()

    /// TODO: thread safety
    fileprivate var settings: CMSSettings?

    private static let cacheKey = "PigeonCMSSettings"

    func get<T: Codable>(setting: WritableKeyPath<CMSSettings, T>,
                         _ request: Request) throws -> Future<T> {
        if let setting = settings?[keyPath: setting] {
            /// by default, return the in-memory setting
            return request.eventLoop.newSucceededFuture(result: setting)
        } else {
            let cache = try request.sharedContainer.make(KeyedCache.self)
            return try self.setting(eventLoop: request.eventLoop, setting, from: cache)
        }
    }

    func allSettings(_ request: Request) throws -> Future<CMSSettings> {
        if let settings = settings {
            return request.future(settings)
        } else {
            return try fetchCachedOrCreateDefaultSettings(request)
        }
    }

    private func setting<T: Codable>(eventLoop: EventLoop,
                                     _ setting: WritableKeyPath<CMSSettings, T>,
                                     from cache: KeyedCache) throws -> Future<T> {
        return cache.get(SettingsService.cacheKey, as: CMSSettings.self).flatMap { cached in
            guard let cached = cached else {
                return try self.createDefaultSettings(cache).map { settings in
                    return settings[keyPath: setting]
                }
            }
            self.settings = cached
            return eventLoop.newSucceededFuture(result: cached[keyPath: setting])
        }
    }

    private func fetchCachedOrCreateDefaultSettings(_ request: Request) throws -> Future<CMSSettings> {
        let cache = try request.sharedContainer.make(KeyedCache.self)
        return cache.get(SettingsService.cacheKey, as: CMSSettings.self).flatMap { cached in
            guard let cached = cached else {
                return try self.createDefaultSettings(cache)
            }
            self.settings = cached
            return request.future(cached)
        }
    }

    private func createDefaultSettings(_ cache: KeyedCache) throws -> Future<CMSSettings> {
        let defaults = CMSSettings.defaults
        self.settings = defaults

        return cache.set(SettingsService.cacheKey, to: defaults).map {
            return defaults
        }
    }

    private init() {
        print("INIT")
    }

}

extension Request {

    func settings() throws -> Future<CMSSettings> {
        return try SettingsService.shared.allSettings(self)
    }

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
