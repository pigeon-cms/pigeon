import Vapor
import FluentPostgreSQL

struct GenericContentCategory: Content, PostgreSQLUUIDModel, Migration {
    var id: UUID?
    var name: String? // "Post"
    var plural: String? // "Posts"
    var items: [GenericContentItem]?
    var template: [GenericContentField]
    // var accessLevel: SomeEnum // TODO: access level for api content
}
