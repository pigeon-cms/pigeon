import Authentication
import FluentPostgreSQL
import Vapor
import Leaf

public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())

//    /// CMS global settings
//    services.register { container in
//        /// TODO: `Services.singleton`
//        return SettingsService()
//    }

    services.register([TemplateRenderer.self, ViewRenderer.self]) { container -> LeafRenderer in
        var tagConfig = LeafTagConfig.default()
        tagConfig.use(JSEscapedFormat(), as: "js")
        tagConfig.use(DateTimeZoneFormat(), as: "date")
        let leafConfig = LeafConfig(tags: tagConfig,
                                    viewsDir: DirectoryConfig.detect().workDir + "Frontend",
                                    shouldCache: container.environment != .development)
        return LeafRenderer(config: leafConfig,
                            using: container)
    }
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    /// Modify date configuration
    let jsonDecoder = JSONDecoder()
    jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601)
    var contentConfig = ContentConfig.default()
    contentConfig.use(decoder: jsonDecoder, for: .json)
    services.register(contentConfig)

    // TODO: create a nice service class for setting up DBs, offer PostgreSQL alternatives
    let user = Environment.get("USER") ?? "root"
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let name = Environment.get("DATABASE_DB") ?? "pigeon"
    let password = Environment.get("DATABASE_PASSWORD")

    // Configure our database, from: `createdb pigeon`
    var databases = DatabasesConfig()
    let databaseConfig = PostgreSQLDatabaseConfig(hostname: hostname,
                                                  username: user,
                                                  database: name,
                                                  password: password)
    databases.add(database: PostgreSQLDatabase(config: databaseConfig), as: .psql)
    services.register(databases)

    var migrations = MigrationConfig()
    migrations.add(migration: ContentState.self, database: .psql)
    migrations.add(model: ContentItem.self, database: .psql)
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: ContentCategory.self, database: .psql)
    migrations.prepareCache(for: .psql)
    services.register(migrations)

    // Configure KeyedCache for database session caching
    services.register(KeyedCache.self) { container in
        try container.keyedCache(for: .psql)
    }

    config.prefer(DatabaseKeyedCache<ConfiguredDatabase<PostgreSQLDatabase>>.self,
                  for: KeyedCache.self)

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
}
