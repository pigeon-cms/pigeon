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

    func graphQLType() throws -> GraphQLOutputType {
        let node = try graphQLNodeType()
        let nodes = GraphQLList(node)

        let edge = try graphQLEdgeType(node)
        let edges = GraphQLList(edge)

        let fields = ["nodes": GraphQLField(type: nodes, resolve: graphQLNodesResolver()),
                      "edges": GraphQLField(type: edges)]
        return try GraphQLObjectType(name: plural.pascalCase(), fields: fields)
    }

    func graphQLNodeType() throws -> GraphQLOutputType {
        let node = try GraphQLObjectType(name: name.pascalCase(), fields: graphQLSingleItemFieldsType())
        return node
    }

    func graphQLEdgeType(_ nodeType: GraphQLOutputType) throws -> GraphQLOutputType {
        let edge = try GraphQLObjectType(name: name.pascalCase() + "Edge",
                                         fields: try graphQLEdgeFields(nodeType))
        return edge
    }

    func graphQLEdgeFields(_ nodeType: GraphQLOutputType) throws -> [String: GraphQLField] {
        var fields = [String: GraphQLField]()
        fields["cursor"] = GraphQLField(type: GraphQLString) // TODO: cursor calculation
        fields["node"] = GraphQLField(type: nodeType) // TODO: resolver

        return fields
    }

    func graphQLSingleItemFieldsType() -> [String: GraphQLField] {
        var fields = [String: GraphQLField]()
        for field in self.template {
            var type = field.type.graphQL
            if field.required {
                type = GraphQLNonNull(type.debugDescription)
            }
            fields[field.name.camelCase()] = GraphQLField(type: type, resolve: graphQLSingleItemResolver(field))
        }

        return fields
    }

    func graphQLNodesResolver() -> GraphQLFieldResolve {
        return { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
            guard let request = eventLoopGroup as? Request else {
                fatalError()
            }
            return try self.items.query(on: request).range(..<25).all().map { items in
                print("Query 1")
                return items
            }
        }
    }

    func graphQLSingleItemResolver(_ field: ContentField) -> GraphQLFieldResolve {
        return { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
            guard let request = eventLoopGroup as? Request else {
                fatalError()
            }
            return try self.items.query(on: request).range(..<25).all().map { items in
                guard let index = info.path[2].indexValue, index < items.count else {
                    throw GraphQLError(message: "Not found")
                }
                print("Query 2")
                /// TODO: This is way cleaner, but lots more requests coming in.
                /// Maybe there's a way to cache a database query per-request? And just fetch request.items for instance
                let item = items[index]
                let contentValue = item.content.first(where: { $0.name == field.name })?.value
                let value = contentValue?.rawValue

                return value
            }
        }
    }

}
