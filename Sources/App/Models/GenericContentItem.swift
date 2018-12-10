import Vapor
import FluentPostgreSQL

struct GenericContentItem: Content, PostgreSQLUUIDModel, Migration {
    var id: UUID?
    var date: Date?
    var authors: [User]?
    var content: [GenericContentField] // All the content for a single item
}

struct GenericContentField: Codable {
    var name: String // "Title"
    var value: SupportedType? // .string("A Post Title")
    var defaultValue: SupportedType?
    var required = false
    // TODO: Define how it's displayed
}

enum SupportedType: Codable, Equatable {
    case string(String?)
    case int(Int?)
    case float(Float?)
    case bool(Bool?)
    case date(Date?)
    case url(URL?)
    case array([SupportedType]?)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = .date(try container.decode(Date.self))
            return
        } catch { }
        do {
            self = .url(try container.decode(URL.self))
            return
        } catch { }
        do {
            self = .int(try container.decode(Int.self))
            return
        } catch { }
        do {
            self = .float(try container.decode(Float.self))
            return
        } catch { }
        do {
            self = .bool(try container.decode(Bool.self))
            return
        } catch { }
        do {
            self = .array(try container.decode([SupportedType].self))
            return
        } catch { }
        do {
            self = .string(try container.decode(String.self))
            return
        } catch { }
        self = .int(-1)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string): try container.encode(string)
        case .int(let int): try container.encode(int)
        case .float(let float): try container.encode(float)
        case .bool(let bool): try container.encode(bool)
        case .date(let date): try container.encode(date)
        case .url(let url): try container.encode(url)
        case .array(let array): try container.encode(array)
        }
    }

    //    init?(rawValue: RawValue) {
    //        switch rawValue {
    //        case "String":
    //            self = .String
    //        case "Int":
    //            self = .Int
    //        case "Float":
    //            self = .Float
    //        case "Bool":
    //            self = .Bool
    //        case "Date":
    //            self = .Date
    //        case "URL":
    //            self = .URL
    //        default:
    //            if let arrayType = SupportedType.parseArrayType(rawValue) {
    //                self = arrayType
    //            } else {
    //                return nil
    //            }
    //        }
    //    }
    //
    //    private static func parseArrayType(_ rawValue: RawValue) -> SupportedType? {
    //        switch rawValue {
    //        case "Array<String>":
    //            return .Array(type: .String)
    //        case "Array<Int>":
    //            return .Array(type: .Int)
    //        case "Array<Float>":
    //            return .Array(type: .Float)
    //        case "Array<Bool>":
    //            return .Array(type: .Bool)
    //        case "Array<Date>":
    //            return .Array(type: .Date)
    //        case "Array<URL>":
    //            return .Array(type: .URL)
    //        default:
    //            return nil
    //        }
    //    }
    //
    //    var rawValue: RawValue {
    //        switch self {
    //        case .String:
    //            return "String"
    //        case .Int:
    //            return "Int"
    //        case .Float:
    //            return "Float"
    //        case .Bool:
    //            return "Bool"
    //        case .Date:
    //            return "Date"
    //        case .URL:
    //            return "URL"
    //        case .Array(type: let arrayType):
    //            return "Array<" + arrayType.rawValue + ">"
    //        }
    //    }
}
