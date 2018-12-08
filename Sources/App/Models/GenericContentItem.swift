import Vapor
import FluentPostgreSQL

struct GenericContentItem: Content, PostgreSQLUUIDModel, Migration {
    var id: UUID?
    var store: [String: Data] // All the content for a single item
}
