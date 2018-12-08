import Vapor
import FluentPostgreSQL

struct GenericContentCategory: Content, PostgreSQLUUIDModel, Migration {
    var id: UUID?
    var name: String // "Post"
    var plural: String // "Posts"
    var items: [GenericContentItem]
    /// Data types for items of this type, eg:
    /// ["Title": "String", "Date": "Date", "Tags": "Array<String>"]
    var types: [String: SupportedType]
    // var accessLevel: SomeEnum // TODO: access level for api content
}

enum SupportedType: Codable, RawRepresentable {
    case String
    case Int
    case Float
    case Bool
    case Date
    case URL
    indirect case array(type: SupportedType)

    typealias RawValue = String

    init?(rawValue: RawValue) {
        switch rawValue {
        case "String":
            self = .String
        case "Int":
            self = .Int
        case "Float":
            self = .Float
        case "Bool":
            self = .Bool
        case "Date":
            self = .Date
        case "URL":
            self = .URL
        default:
            if let arrayType = SupportedType.parseArrayType(rawValue) {
                self = arrayType
            } else {
                return nil
            }
        }
    }

    private static func parseArrayType(_ rawValue: RawValue) -> SupportedType? {
        return nil // TODO
    }

    var rawValue: RawValue {
        return "String" // TOOD
    }
}
