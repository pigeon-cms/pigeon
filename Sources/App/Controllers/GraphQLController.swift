import Vapor
import GraphQL

class GraphQLController: PigeonController {

    override func authBoot(router: Router) throws {
        router.post(["/graphql", String.parameter], use: graphQLHandler)
    }

}

private extension GraphQLController {

    struct GraphQLHTTPBody: Codable {
        var query: String
//        var variables: [String: Any]? // TODO: codable representation of "any" json type
    }

    func graphQLHandler(_ request: Request) throws -> Future<Response> {
        guard let typeName = try request.parameters.next(String.self).removingPercentEncoding else {
            throw Abort(.notFound)
        }

        guard let json = try? request.content.decode(json: GraphQLHTTPBody.self, using: JSONDecoder()) else {
            throw Abort(.badRequest)
        }

        return json.flatMap { query in
            let queryString = query.query

            let schema = try GraphQLSchema(
                query: GraphQLObjectType(
                    name: "RootQueryType",
                    fields: [
                        "hello": GraphQLField(
                            type: GraphQLString,
                            resolve: { _, _, _, eventLoopGroup, _ in
                                return eventLoopGroup.next().newSucceededFuture(result: typeName)
                        })
                    ]
                )
            )

            let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            return try graphql(schema: schema, request: queryString, eventLoopGroup: eventLoopGroup).map { map in
                let map = try map.asMap()
                let data = "\(map)".data(using: .utf8)
                return Response(http: HTTPResponse.init(status: .ok, body: data!),
                                using: request.sharedContainer)
            }
        }
    }
    
}
