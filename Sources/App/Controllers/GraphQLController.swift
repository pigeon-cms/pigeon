import Vapor
import GraphQL
import Pagination

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

            let pageInfo = try self.graphQLPageInfoType()

            for type in contentTypes {
                rootFields[type.plural.camelCase()] = try GraphQLField(
                    type: type.graphQLType(pageInfo),
                    args: type.graphQLPaginationArgs(),
                    resolve: type.rootResolver()
                )
            }

            let schema = try GraphQLSchema(
                query: GraphQLObjectType(
                    name: "RootQueryType",
                    fields: rootFields)
            )
            return schema
        }
    }

    func graphQLPageInfoType() throws -> GraphQLOutputType {
        var fields = [String: GraphQLField]()
        fields["current"] = GraphQLField(type: GraphQLInt, resolve: paginationResolver())
        fields["size"] = GraphQLField(type: GraphQLInt, resolve: paginationResolver())
        fields["total"] = GraphQLField(type: GraphQLInt, resolve: paginationResolver())

        let pageInfo = try GraphQLObjectType(name: "PageInfo",
                                             fields: fields)
        return pageInfo
    }

    func paginationResolver() -> GraphQLFieldResolve {
        return { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
            guard let page = source as? Page<ContentItem> else {
                throw Abort(.serviceUnavailable)
            }
            guard info.path.count > 2 else {
                throw Abort(.serviceUnavailable)
            }
            switch info.path[2].keyValue {
            case "current":
                return eventLoopGroup.next().newSucceededFuture(result: page.number)
            case "total":
                return eventLoopGroup.next().newSucceededFuture(result: Int(ceil(Float(page.total) / Float(page.size))))
            case "size":
                return eventLoopGroup.next().newSucceededFuture(result: page.size)
            default:
                throw Abort(.serviceUnavailable)
            }
        }
    }

    func graphQLResponse(for query: GraphQLHTTPBody, _ request: Request) throws -> Future<Response> {
        return try self.schema(request).flatMap { schema in
            return try graphql(schema: schema, request: query.query, eventLoopGroup: request).map { map in
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
        struct GraphQLPage: Codable {
            var path: String
        }
        if request.http.accept.contains(where: { $0.mediaType.type == "text" && $0.mediaType.subType == "html" }) {
            return try request.view().render("GraphQL/graphql-playground", GraphQLPage(path: "/graphql")) // TODO: query path not hardcoded
        }
        throw Abort(.notFound) // TODO: GraphQL GET queries
    }


    
}
