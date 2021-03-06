import Vapor
import Pagination
import FluentPostgreSQL

final class ContentItem: Content, Paginatable, PostgreSQLUUIDModel, Migration {
    var id: UUID?
    var categoryID: UUID
    var state: ContentState
    var created: Date?
    var updated: Date?
    var scheduled: Date?
    var published: Date?
    var authors: [PublicUser]?
    var content: [ContentField] // All the content for a single item
    var category: Parent<ContentItem, ContentCategory> {
        return parent(\.categoryID)
    }
    static var defaultPageSorts: [ContentItem.Database.QuerySort] {
        return [
            ContentItem.Database.querySort(ContentItem.Database.queryField(.keyPath(\ContentItem.published)),
                                           .descending),
            ContentItem.Database.querySort(ContentItem.Database.queryField(.keyPath(\ContentItem.created)),
                                           .descending)
        ]
    }
}

final class ContentItemPublic: Content {
    var created: Date?
    var updated: Date?
    var published: Date?
    var state: ContentState
    var content: [String: SupportedValue]
    var authors: [[String: String?]]

    init(_ item: ContentItem) {
        created = item.created
        updated = item.updated
        published = item.published
        state = item.state
        content = item.content.reduce([String: SupportedValue]()) { dict, field in
            var dict = dict
            dict[field.name.camelCase()] = field.value
            return dict
        }
        authors = item.authors?.compactMap { ["name": $0.name] } ?? []
    }
}
