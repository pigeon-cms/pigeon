import Vapor
import FluentPostgreSQL

enum ContentState: Content, ReflectionDecodable, Equatable, RawRepresentable  {
    typealias RawValue = String

    case draft
    /// TODO: scheduled(Date)
    case published

    init?(rawValue: RawValue) {
        switch rawValue {
        case "draft": self = .draft
        case "published": self = .published
        default: self = .draft
        }
    }

    var rawValue: RawValue {
        switch self {
        case .draft: return "draft"
        case .published: return "published"
        }
    }

    static func reflectDecoded() throws -> (ContentState, ContentState) {
        return (.draft, .published)
    }
}
