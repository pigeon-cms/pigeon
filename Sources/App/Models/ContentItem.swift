import Vapor
import Pagination
import FluentPostgreSQL

final class ContentItem: Content, Paginatable, PostgreSQLUUIDModel, Migration {
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
