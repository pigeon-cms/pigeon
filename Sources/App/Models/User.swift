import Vapor
import FluentPostgreSQL

struct User: Content, PostgreSQLUUIDModel, Migration {
    var id: UUID?
    private(set) var email: String
    private(set) var passwordHash: String
}
