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
        let node = try GraphQLObjectType(name: name.pascalCase(), fields: graphQLSingleItemFieldsType(request))
        let nodes = GraphQLList(node)

        let fields = ["nodes": GraphQLField(type: nodes, resolve: graphQLNodesResolver(request))]
        return try GraphQLObjectType(name: plural.pascalCase(), fields: fields)
    }

    func graphQLSingleItemFieldsType(_ request: Request) -> [String: GraphQLField] {
        var fields = [String: GraphQLField]()
        for field in self.template {
            var type = field.type.graphQL
            if field.required {
                type = GraphQLNonNull(type.debugDescription)
            }
            fields[field.name.camelCase()] = GraphQLField(type: type, resolve: graphQLSingleItemResolver(field, request))
        }

        return fields
    }

    func graphQLNodesResolver(_ request: Request) -> GraphQLFieldResolve {
        return { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
            return try self.items.query(on: request).range(..<25).all().map { items in
                print("Query 1")
                return items
            }
        }
    }

    func graphQLSingleItemResolver(_ field: ContentField, _ request: Request) -> GraphQLFieldResolve {
        return { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
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
//    func graphQLType(_ request: Request) throws -> Future<GraphQLOutputType> {
//        return try graphQLFields(request).map { fields in
//            let type = try GraphQLObjectType(name: self.plural.pascalCase(), fields: fields)
//            return type
//        }
//    }

//    /// GraphQL fields including nodes and TODO: edges
//    func graphQLFields(_ request: Request) throws -> Future<[String: GraphQLField]> {
//        return try graphQLSingleItemFields(request).map { singleItemFields in
//            let node = try GraphQLObjectType(name: self.name.pascalCase(), fields: singleItemFields)
//            let fields = ["nodes": GraphQLField(type: GraphQLList(node), resolve: { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
//                return eventLoopGroup.next().newSucceededFuture(result: ["hmm", "hmm", "hmm", "hmm", "hmm"])
//            })]
//            return fields
//        }
//
//    }
//
//    /// The fields for a single item of this type.
//    func graphQLSingleItemFields(_ request: Request) throws -> Future<[String: GraphQLField]> {
//        return try request.contentCategory(type: self.plural).flatMap { category in
//            return try category.items.query(on: request).range(..<25).all().map { items in
//                // TODO: post limit from settings instead of hardcoded
//                print("QUERY 1")
//
//                var fields = [String: GraphQLField]()
//                for field in self.template {
//                    var type = field.type.graphQL
//                    if field.required {
//                        type = GraphQLNonNull(type.debugDescription)
//                    }
//                    fields[field.name.camelCase()] = GraphQLField(type: type, resolve: { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
//                        guard let index = info.path[2].indexValue, index < items.count else {
//                            return eventLoopGroup.next().newFailedFuture(error: GraphQLError(message: "Not found"))
//                        }
//
//                        let item = items[index]
//                        let contentValue = item.content.first(where: { $0.name == field.name })?.value
//                        let value = contentValue?.rawValue
//
//                        return eventLoopGroup.next().newSucceededFuture(result: value)
//                    })
//                }
//                return fields
//            }
//        }
//    }

}
