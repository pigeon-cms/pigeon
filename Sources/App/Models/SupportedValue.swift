import Vapor
import Foundation

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
