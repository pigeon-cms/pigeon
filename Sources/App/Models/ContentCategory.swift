import Vapor
import FluentPostgreSQL
import CursorPagination
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
                      "edges": GraphQLField(type: edges,
                                            args: graphQLFirstAfterArgs(),
                                            resolve: graphQLEdgesResolver())]
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

    func graphQLFirstAfterArgs() -> GraphQLArgumentConfigMap {
        let first = GraphQLArgument(
            type: GraphQLInt,
            description: "The number of items to return after the referenced “after” cursor",
            defaultValue: "20"
        )
        let after = GraphQLArgument(
            type: GraphQLString,
            description: "Cursor used along with the “first” argument to reference where in the dataset to get data"
        )
        return ["first": first,
                "after": after]
    }

    func graphQLEdgeFields(_ nodeType: GraphQLOutputType) throws -> [String: GraphQLField] {
        var fields = [String: GraphQLField]()
        fields["cursor"] = GraphQLField(type: GraphQLString, resolve: graphQLEdgeCursorResolver())
        fields["node"] = GraphQLField(type: nodeType, resolve: graphQLEdgeNodeResolver())

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
                throw Abort(.serviceUnavailable)
            }
             /// TODO: not hardcoded
            return try self.items.query(on: request).range(..<25).all().map { items in
                return items
            }
        }
    }

    func graphQLEdgesResolver() -> GraphQLFieldResolve {
        return { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
            guard let request = eventLoopGroup as? Request else {
                throw Abort(.serviceUnavailable)
            }

            let first = min(args["first"].int ?? 20, 20) /// TODO: not hardcoded upper limit
            let cursor = args["cursor"].string
        
            return try self.items.query(on: request).paginate(cursor: cursor,
                                                              sorts: [.descending(\.fluentID)]).map { items in
                print(items)
                return items.data
            }.mapIfError { error in
                print(error)
                return nil
            }
        }
    }

    func graphQLEdgeNodeResolver() -> GraphQLFieldResolve {
        return { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
            guard let item = source as? ContentItem else {
                throw Abort(.serviceUnavailable)
            }
            return eventLoopGroup.next().newSucceededFuture(result: item)
        }
    }

    func graphQLEdgeCursorResolver() -> GraphQLFieldResolve {
        return { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
            guard let item = source as? ContentItem else {
                throw Abort(.serviceUnavailable)
            }
            /// TODO: cursor calculation from item
            return eventLoopGroup.next().newSucceededFuture(result: "SADKFNSDKFJN")
        }
    }


    func graphQLSingleItemResolver(_ field: ContentField) -> GraphQLFieldResolve {
        return { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
            guard let item = source as? ContentItem else {
                throw Abort(.serviceUnavailable)
            }

            let contentValue = item.content.first(where: { $0.name == field.name })?.value
            let value = contentValue?.rawValue
            return eventLoopGroup.next().newSucceededFuture(result: value)
        }
    }

}
