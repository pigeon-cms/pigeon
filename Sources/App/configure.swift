import Authentication
import FluentPostgreSQL
import Vapor
import Leaf

public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self) // TODO: database?

    /// Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())

    services.register([TemplateRenderer.self, ViewRenderer.self]) { container -> LeafRenderer in
        let leafConfig = LeafConfig(tags: LeafTagConfig.default(),
                                    viewsDir: DirectoryConfig.detect().workDir + "Frontend",
                                    shouldCache: container.environment != .development)
        return LeafRenderer(config: leafConfig,
                            using: container)
    }

    let user = Environment.get("USER") ?? "root"
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let name = Environment.get("DATABASE_DB") ?? "pigeon"
    // Configure our database, from: `createdb pigeon`
    var databases = DatabasesConfig()
    let databaseConfig = PostgreSQLDatabaseConfig(hostname: hostname,
                                                  username: user,
                                                  database: name)
    databases.add(database: PostgreSQLDatabase(config: databaseConfig), as: .psql)
    services.register(databases)

    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    services.register(migrations)

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
