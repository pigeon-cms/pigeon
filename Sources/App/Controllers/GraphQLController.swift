import Vapor
import GraphQL
import AnyCodable

class GraphQLController: PigeonController {

    override func authBoot(router: Router) throws {
        router.post(["/graphql"], use: graphQLPostQueryHandler)
        router.get(["/graphql"], use: graphQLGetQueryHandler)
    }

}

private extension GraphQLController {

    struct GraphQLHTTPBody: Codable {
        var query: String
        var variables: [String: AnyCodable]? // TODO: codable representation of "any" json type
    }

    func schema(_ request: Request) throws -> Future<GraphQLSchema> {
        return try request.graphQLSchema()
    }

    func graphQLResponse(for query: GraphQLHTTPBody, _ request: Request) throws -> Future<Response> {
        return try self.schema(request).flatMap { schema in
            return try graphql(
                schema: schema,
                request: query.query,
                eventLoopGroup: request,
                variableValues: try (query.variables?.mapValues({ $0.value }) ?? [:]).asMap().asDictionary()
            ).map { map in
                let map = try map.asMap()
                guard let data = "\(map)".data(using: .utf8) else { throw Abort(.badRequest) }
                return Response(http: HTTPResponse.init(status: .ok, body: data),
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
        if request.http.accept.contains(where: { $0.mediaType.type == "text" && $0.mediaType.subType == "html" }) {
            return try request.view().render("GraphQL/graphql-playground") // TODO: query path not hardcoded
        }
        throw Abort(.notFound) // TODO: GraphQL GET queries
    }

}
