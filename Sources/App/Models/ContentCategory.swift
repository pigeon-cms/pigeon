import Vapor
import FluentPostgreSQL
import GraphQL

final class ContentCategory: Content, PostgreSQLUUIDModel, Migration {
    var id: UUID?
    var name: String // "Post"
    var plural: String // "Posts"
    var items: Children<ContentCategory, ContentItem> {
        return children(\.categoryID)
    }
    var template: [ContentField]
    // var accessLevel: SomeEnum // TODO: access level for api content

    func graphQLFields() -> [String: GraphQLField] {
        var fields = [String: GraphQLField]()
        for field in template {
            var type = field.type.graphQL
            if field.required {
                type = GraphQLNonNull(type.debugDescription)
            }
            fields[field.name.camelCase()] = GraphQLField(type: type, resolve: { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
                // TODO: actually fetch stuff
                return eventLoopGroup.next().newSucceededFuture(result: "Hello world")
            })
        }
        return fields
    }

    func graphQLType() throws -> GraphQLOutputType {
        let type = try GraphQLObjectType(name: plural.pascalCase(), fields: graphQLFields())
        return type
    }
}
