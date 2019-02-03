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
                let graphQLType = try type.graphQLType(request)
                rootFields[type.plural.camelCase()] = GraphQLField(type: graphQLType, resolve: { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
                    return eventLoopGroup.next().newSucceededFuture(result: graphQLType)
                })
            }
            let schema = try GraphQLSchema(
                query: GraphQLObjectType(
                        name: "RootQueryType",
                        fields: rootFields)
            )
            return schema
        }
    }

    func graphQLResponse(for query: GraphQLHTTPBody, _ request: Request) throws -> Future<Response> {
        return try self.schema(request).flatMap { schema in
            let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1) // TODO: is this necessary
            return try graphql(schema: schema, request: query.query, eventLoopGroup: eventLoopGroup).map { map in
                let map = try map.asMap()
                let data = "\(map)".data(using: .utf8)
                return Response(http: HTTPResponse.init(status: .ok, body: data!),
                                using: request.sharedContainer)
            }
        }
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
