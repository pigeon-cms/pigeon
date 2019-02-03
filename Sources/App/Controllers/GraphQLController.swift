import Vapor
import GraphQL

class GraphQLController: PigeonController {

    override func authBoot(router: Router) throws {
        router.post(["/graphql", String.parameter], use: graphQLPostQueryHandler)
        router.get(["/graphql", String.parameter], use: graphQLGetQueryHandler)
    }

}

private extension GraphQLController {

    struct GraphQLHTTPBody: Codable {
        var query: String
//        var variables: [String: Any]? // TODO: codable representation of "any" json type
    }

    func graphQLPostQueryHandler(_ request: Request) throws -> Future<Response> {
        guard let typeName = try request.parameters.next(String.self).removingPercentEncoding else {
            throw Abort(.notFound)
        }

        guard let json = try? request.content.decode(json: GraphQLHTTPBody.self, using: JSONDecoder()) else {
            throw Abort(.badRequest)
        }

        return json.flatMap { query in

            return try request.contentCategory(type: typeName).flatMap { category in
                let queryString = query.query

                let schema = try category.createGraphQLSchema()

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

    func graphQLGetQueryHandler(_ request: Request) throws -> Future<View> {
        struct GraphiQLPage: Codable {
            var path: String
        }
        if request.http.accept.contains(where: { $0.mediaType.type == "text" && $0.mediaType.subType == "html" }) {
            return try request.view().render("graphiql", GraphiQLPage(path: "/graphql/Status%20Messages")) // TODO: query not hardcoded
        }
        fatalError("TODO: Need to implement GET GraphQL queries")
    }
    
}
