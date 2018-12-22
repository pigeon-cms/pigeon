import Vapor
import Authentication
import FluentPostgreSQL

struct PublicUser: Content {
    var name: String?
    var privileges: UserPrivileges?
    var timezoneOffset: Float?

    init(_ user: User) {
        name = user.name
        privileges = user.privileges
        timezoneOffset = user.timezoneOffset
    }
}

struct User: Content, PostgreSQLUUIDModel, Migration {
    var id: UUID?
    var name: String?
    var privileges: UserPrivileges?
    var timezoneOffset: Float?
    private(set) var email: String
    private(set) var password: String

    var publicUser: PublicUser {
        return PublicUser(self)
    }
}

enum UserPrivileges: Int, Codable, Equatable {
    /// Can edit existing content types
    case user
    /// Can create new content types and edit existing types
    case editor
    /// Can create and edit content types and user accounts
    case administrator
    /// Full priveleges, an owner account is the origin account
    case owner
}

extension User: BasicAuthenticatable {
    static let usernameKey: WritableKeyPath<User, String> = \.email
    static let passwordKey: WritableKeyPath<User, String> = \.password
}

extension User: SessionAuthenticatable { }
