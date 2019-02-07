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

    func graphQLType(_ request: Request) throws -> GraphQLOutputType {
        let type = try GraphQLObjectType(name: plural.pascalCase(), fields: graphQLFields(request))
        return type
    }

    /// GraphQL fields including nodes and TODO: edges
    func graphQLFields(_ request: Request) throws -> [String: GraphQLField] {
        let node = try GraphQLObjectType(name: name.pascalCase(), fields: graphQLSingleItemFields(request))
        let fields = ["nodes": GraphQLField(type: GraphQLList(node), resolve: try graphQLNodesResolver(request))]
        return fields
    }

    func graphQLNodesResolver(_ request: Request) throws -> GraphQLFieldResolve {
        return { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
            return try request.contentCategory(type: self.plural).flatMap { category in
                return try category.items.query(on: request).range(..<25).all().map { items in
                    print("QUERY 2")
                    // TODO: post limit from settings instead of hardcoded
                    return items.map { self.graphQLSingleItemFields(item: $0) }
                }
            }
        }
    }

    /// The fields for a single item of this type.
    func graphQLSingleItemFields(_ request: Request) -> [String: GraphQLField] {
        var fields = [String: GraphQLField]()
        for field in template {
            var type = field.type.graphQL
            if field.required {
                type = GraphQLNonNull(type.debugDescription)
            }
            fields[field.name.camelCase()] = GraphQLField(type: type, resolve: { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
                return try request.contentCategory(type: self.plural).flatMap { category in
                    return try category.items.query(on: request).range(..<25).all().flatMap { items in
                        print("QUERY 1")
                        // TODO: post limit from settings instead of hardcoded
                        guard let index = info.path[2].indexValue else {
                            return eventLoopGroup.next().newFailedFuture(error: GraphQLError(message: "Not found"))
                        }

                        let item = items[index]
                        let contentValue = item.content.first(where: { $0.name == field.name })?.value
                        let value = contentValue?.rawValue

                        return eventLoopGroup.next().newSucceededFuture(result: value)
                    }
                }
            })
        }
        return fields
    }

    /// The fields for a single item of this type.
    func graphQLSingleItemFields(item: ContentItem) -> [String: GraphQLField] {
        var fields = [String: GraphQLField]()
        for field in item.content {
            var type = field.type.graphQL
            if field.required {
                type = GraphQLNonNull(type.debugDescription)
            }
            fields[field.name.camelCase()] = GraphQLField(type: type, resolve: { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
                return eventLoopGroup.next().newSucceededFuture(result: field.value.rawValue)
            })
        }
        return fields
    }

}
