import Vapor
import FluentPostgreSQL

struct GenericContentItem: Content, PostgreSQLUUIDModel, Migration {
    var id: UUID?
    var categoryID: UUID
    var date: Date?
    var authors: [User]?
    var content: [GenericContentField] // All the content for a single item
    var category: Parent<GenericContentItem, GenericContentCategory> {
        return parent(\.categoryID)
    }
}

struct GenericContentField: Content {
    var name: String // "Title"
    var type: SupportedType
    var value: SupportedValue // .string("A Post Title")
    var required: Bool
    // TODO: Define how it's displayed

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(SupportedType.self, forKey: .type)
        required = try container.decode(Bool.self, forKey: .required)
        switch type {
        case .String: value = SupportedValue.string(try? container.decode(String.self, forKey: .value))
        case .Int: value = SupportedValue.int(try? container.decode(Int.self, forKey: .value))
        case .Float: value = SupportedValue.float(try? container.decode(Float.self, forKey: .value))
        case .Bool: value = SupportedValue.bool(try? container.decode(Bool.self, forKey: .value))
        case .Date: value = SupportedValue.date(try? container.decode(Date.self, forKey: .value))
        case .URL: value = SupportedValue.url(try? container.decode(URL.self, forKey: .value))
        case .Array:
            fatalError() // TODO
        }
    }
}

//struct SupportedTypeValue: Content, Equatable {
//    typealias RawValue = String
//
//    let type: SupportedType
//    var value: SupportedValue?
//
//    init(type: SupportedType) {
//        self.type = type
//    }
//}

enum SupportedType: Content, ReflectionDecodable, Equatable, RawRepresentable {
    typealias RawValue = String
    
    case String
    case Int
    case Float
    case Bool
    case Date
    case URL
    indirect case Array(SupportedType)
    
    init?(rawValue: RawValue) {
        switch rawValue {
        case "String": self = .String
        case "Int": self = .Int
        case "Float": self = .Float
        case "Bool": self = .Bool
        case "Date": self = .Date
        case "URL": self = .URL
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
        case "Array<String>": return .Array(.String)
        case "Array<Int>": return .Array(.Int)
        case "Array<Float>": return .Array(.Float)
        case "Array<Bool>": return .Array(.Bool)
        case "Array<Date>": return .Array(.Date)
        case "Array<URL>": return .Array(.URL)
        default:
            return nil
        }
    }

    var rawValue: RawValue {
        switch self {
        case .String: return "String"
        case .Int: return "Int"
        case .Float: return "Float"
        case .Bool: return "Bool"
        case .Date: return "Date"
        case .URL: return "URL"
        case .Array(let type): return "Array<" + type.rawValue + ">"
        }
    }

    static func reflectDecoded() throws -> (SupportedType, SupportedType) {
        return (.String, .Int)
    }
}

enum SupportedValue: Content, Equatable {
    case string(String?)
    case int(Int?)
    case float(Float?)
    case bool(Bool?)
    case date(Date?)
    case url(URL?)
    case array([SupportedValue]?)

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
            self = .array(try container.decode([SupportedValue].self))
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
}
