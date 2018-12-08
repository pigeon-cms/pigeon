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
    indirect case Array(type: SupportedType)

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
        switch rawValue {
        case "Array<String>":
            return .Array(type: .String)
        case "Array<Int>":
            return .Array(type: .Int)
        case "Array<Float>":
            return .Array(type: .Float)
        case "Array<Bool>":
            return .Array(type: .Bool)
        case "Array<Date>":
            return .Array(type: .Date)
        case "Array<URL>":
            return .Array(type: .URL)
        default:
            return nil
        }
    }

    var rawValue: RawValue {
        switch self {
        case .String:
            return "String"
        case .Int:
            return "Int"
        case .Float:
            return "Float"
        case .Bool:
            return "Bool"
        case .Date:
            return "Date"
        case .URL:
            return "URL"
        case .Array(type: let arrayType):
            return "Array<" + arrayType.rawValue + ">"
        }
    }
}
