import Vapor
import Authentication
import FluentPostgreSQL

struct User: Content, PostgreSQLUUIDModel, Migration {
    var id: UUID?
    var name: String?
    private(set) var email: String
    private(set) var password: String
}

extension User: BasicAuthenticatable {
    static let usernameKey: WritableKeyPath<User, String> = \.email
    static let passwordKey: WritableKeyPath<User, String> = \.password
}

extension User: SessionAuthenticatable { }
