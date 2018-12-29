import Vapor
import Authentication
import FluentPostgreSQL

struct PublicUser: Content {
    var name: String?
    var email: String?
    var privileges: String?
    var timeZoneName: String?
    var timeZoneAbbreviation: String?

    init(_ user: User) {
        name = user.name
        email = user.email
        privileges = user.privileges?.toString()
        timeZoneName = user.timeZoneName
        let timeZone = TimeZone(identifier: timeZoneName ?? "") ?? TimeZone.autoupdatingCurrent
        timeZoneAbbreviation = timeZone.abbreviation(for: Date())
    }
}

struct User: Content, PostgreSQLUUIDModel, Migration {
    var id: UUID?
    var name: String?
    var privileges: UserPrivileges?
    var timeZoneName: String?
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
    
    func toString() -> String {
        switch self {
        case .user: return "User"
        case .editor: return "Editor"
        case .administrator: return "Administrator"
        case .owner: return "Owner"
        }
    }
}

extension User: BasicAuthenticatable {
    static let usernameKey: WritableKeyPath<User, String> = \.email
    static let passwordKey: WritableKeyPath<User, String> = \.password
}

extension User: SessionAuthenticatable { }
