import Vapor
import FluentPostgreSQL

final class ContentCategory: Content, PostgreSQLUUIDModel, Migration {
    var id: UUID?
    var name: String // "Post"
    var plural: String // "Posts"
    var items: Children<ContentCategory, ContentItem> {
        return children(\.categoryID)
    }
    var template: [String: ContentField]
    // var accessLevel: SomeEnum // TODO: access level for api content
}
