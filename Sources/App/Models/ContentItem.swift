import Vapor
import Pagination
import CursorPagination
import FluentPostgreSQL

final class ContentItem: Content, Paginatable, CursorPaginatable, PostgreSQLUUIDModel, Migration {
    var id: UUID?
    var categoryID: UUID
    var created: Date?
    var updated: Date?
    var authors: [PublicUser]?
    var content: [ContentField] // All the content for a single item
    var category: Parent<ContentItem, ContentCategory> {
        return parent(\.categoryID)
    }
}

/// TODO: instead of this, need to figure out how to structure the actual content this way,
/// with an 'order' property for the CMS display, and a way to hide props like 'id' and 'order'.
final class ContentItemPublic: Content {
    var created: Date?
    var updated: Date?
    var content: [String: SupportedValue]
    var authors: [[String: String?]]

    init(_ item: ContentItem) {
        created = item.created
        updated = item.updated
        content = item.content.reduce([String: SupportedValue]()) { dict, field in
            var dict = dict
            dict[field.name.camelCase()] = field.value
            return dict
        }
        authors = item.authors?.compactMap { ["name": $0.name] } ?? []
    }
}

enum SupportedType: Content, ReflectionDecodable, Equatable, RawRepresentable {
    typealias RawValue = String

    case string
    case int
    case float
    case bool
    case date
    case url
    indirect case array(SupportedType)

    init?(rawValue: RawValue) {
        switch rawValue {
        case "String": self = .string
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

enum SupportedValue: Content, Equatable, TemplateDataRepresentable {
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

    func convertToTemplateData() throws -> TemplateData {
        switch self {
        case .string(let string):
            guard let string = string else {
                return TemplateData.null
            }
            return TemplateData.string(string)
        case .int(let int):
            guard let int = int else {
                return TemplateData.null
            }
            return TemplateData.int(int)
        case .float(let float):
            guard let float = float else {
                return TemplateData.null
            }
            return TemplateData.double(Double(float))
        case .bool(let bool):
            guard let bool = bool else {
                return TemplateData.null
            }
            return TemplateData.bool(bool)
        case .date(let date):
            guard let date = date else {
                return TemplateData.null
            }
            return TemplateData.null // TODO: template date?
        case .url(let url):
            guard let url = url else {
                return TemplateData.null
            }
            return TemplateData.string(url.absoluteString)
        case .array(let array):
            return TemplateData.null // TODO: template array
        }
    }
}
