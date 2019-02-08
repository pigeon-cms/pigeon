import Vapor
import GraphQL

class GraphQLController: PigeonController {

    override func authBoot(router: Router) throws {
        router.post(["/graphql"], use: graphQLPostQueryHandler)
        router.get(["/graphql"], use: graphQLGetQueryHandler)
    }

}

private extension GraphQLController {

    struct GraphQLHTTPBody: Codable {
        var query: String
        var variables: [String: SupportedValue]? // TODO: codable representation of "any" json type
    }

    func schema(_ request: Request) throws -> Future<GraphQLSchema> {
        return request.allContentTypes().map { contentTypes in
            var rootFields = [String: GraphQLField]()

            for type in contentTypes {
                rootFields[type.plural.camelCase()] = try GraphQLField(type: type.graphQLType(request), resolve: { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
                    return eventLoopGroup.next().newSucceededFuture(result: type)
                })
            }

            let schema = try GraphQLSchema(
                query: GraphQLObjectType(
                    name: "RootQueryType",
                    fields: rootFields)
            )
            return schema
//            return try contentTypes.compactMap { try $0.graphQLType(request) }.flatten(on: request.eventLoop).map { graphQLTypes in
//                var rootFields = [String: GraphQLField]()
//                for type in graphQLTypes {
//                    rootFields[type.debugDescription] = GraphQLField(type: type, resolve: { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
//                        return eventLoopGroup.next().newSucceededFuture(result: type)
//                    })
//                }
//                let schema = try GraphQLSchema(
//                    query: GraphQLObjectType(
//                        name: "RootQueryType",
//                        fields: rootFields)
//                )
//                return schema
//            }
        }

//    func schema(_ request: Request) throws -> Future<Schema<NoRoot, NoContext, MultiThreadedEventLoopGroup>> {
//        return request.allContentTypes().map { contentTypes in
//            print("QUERY 1")
//            return try Schema<NoRoot, NoContext, MultiThreadedEventLoopGroup> { schema in
//                try schema.query { query in
//                    for type in contentTypes {
//                        try query.field(name: type.plural.camelCase(), type: String.self) { (_, _, _, eventLoop, _) in
////                            eventLoop.next().newSucceededFuture(result: type)
//                            fatalError()
//                        }
//                    }
//                }
//            }
//        }

//        return request.allContentTypes().flatMap { contentTypes in
//            return try contentTypes.compactMap { try $0.graphQLType(request) }.flatten(on: request.eventLoop).map { graphQLTypes in
//                var rootFields = [String: GraphQLField]()
//                for type in graphQLTypes {
//                    rootFields[type.debugDescription] = GraphQLField(type: type, resolve: { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
//                        return eventLoopGroup.next().newSucceededFuture(result: type)
//                    })
//                }
//                let schema = try GraphQLSchema(
//                    query: GraphQLObjectType(
//                        name: "RootQueryType",
//                        fields: rootFields)
//                )
//                return schema
//            }
//        }
    }

    func graphQLResponse(for query: GraphQLHTTPBody, _ request: Request) throws -> Future<Response> {
        return try self.schema(request).flatMap { schema in
            return try graphql(schema: schema, request: query.query, eventLoopGroup: request.eventLoop).map { map in
                let map = try map.asMap()
                guard let data = "\(map)".data(using: .utf8) else { throw Abort(.badRequest) }
                return Response(http: HTTPResponse.init(status: .ok, body: data),
                                using: request.sharedContainer)
            }
        }

//        return try schema(request).flatMap { schema in
////            let eventGroup = request.eventLoop()
//            let eventGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
//            return try schema.execute(request: query.query, eventLoopGroup: eventGroup).map { map in
//                guard let data = "\(map)".data(using: .utf8) else { throw Abort(.badRequest) }
//                return Response(http: HTTPResponse.init(status: .ok, body: data),
//                                using: request.sharedContainer)
//            }
//        }
    }

    func graphQLPostQueryHandler(_ request: Request) throws -> Future<Response> {
        guard let json = try? request.content.decode(json: GraphQLHTTPBody.self, using: JSONDecoder()) else {
            throw Abort(.badRequest)
        }

        return json.flatMap { query in
            return try self.graphQLResponse(for: query, request)
        }
    }

    func graphQLGetQueryHandler(_ request: Request) throws -> Future<View> {
        struct GraphiQLPage: Codable {
            var path: String
        }
        if request.http.accept.contains(where: { $0.mediaType.type == "text" && $0.mediaType.subType == "html" }) {
            return try request.view().render("graphiql", GraphiQLPage(path: "/graphql")) // TODO: query not hardcoded
        }
        fatalError("TODO: Need to implement GET GraphQL queries")
    }
    
}
