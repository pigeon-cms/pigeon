import Vapor
import Fluent
import Foundation

enum SupportedType: Content, ReflectionDecodable, Equatable, RawRepresentable {
    typealias RawValue = String

    case string
    case markdown
    case int
    case float
    case bool
    case date
    case url
    indirect case array(SupportedType)

    init?(rawValue: RawValue) {
        switch rawValue {
        case "String": self = .string
        case "Markdown": self = .markdown
        case "Int": self = .int
        case "Float": self = .float
        case "Bool": self = .bool
        case "Date": self = .date
        case "URL": self = .url
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
        case "Array<String>": return .array(.string)
        case "Array<Int>": return .array(.int)
        case "Array<Float>": return .array(.float)
        case "Array<Bool>": return .array(.bool)
        case "Array<Date>": return .array(.date)
        case "Array<URL>": return .array(.url)
        default:
            return nil
        }
    }

    var rawValue: RawValue {
        switch self {
        case .string: return "String"
        case .markdown: return "Markdown"
        case .int: return "Int"
        case .float: return "Float"
        case .bool: return "Bool"
        case .date: return "Date"
        case .url: return "URL"
        case .array(let type): return "Array<" + type.rawValue + ">"
        }
    }

    static func reflectDecoded() throws -> (SupportedType, SupportedType) {
        return (.string, .int)
    }
}
