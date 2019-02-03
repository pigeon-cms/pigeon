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

    func createGraphQLSchema() throws -> GraphQLSchema {
        let schema = try GraphQLSchema(
            query: GraphQLObjectType(
                name: "RootQueryType",
                fields: graphQLFields()
            )
        )
        return schema
    }

    func graphQLFields() -> [String: GraphQLField] {
        var fields = [String: GraphQLField]()
        for field in template {
            fields[field.name] = GraphQLField(type: field.type.graphQL, resolve: { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
                return eventLoopGroup.next().newSucceededFuture(result: "Hello world")
            })
        }
        return fields
    }
}
