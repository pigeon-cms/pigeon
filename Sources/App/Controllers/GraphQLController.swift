import Vapor
import GraphQL

class GraphQLController: PigeonController {

    override func authBoot(router: Router) throws {
        router.post(["/graphql", String.parameter], use: graphQLHandler)
    }

}

private extension GraphQLController {

    func graphQLHandler(_ request: Request) throws -> Future<Response> {
        guard let typeName = try request.parameters.next(String.self).removingPercentEncoding else {
            throw Abort(.notFound)
        }

        guard let queryData = request.http.body.data,
            let queryString = String(data: queryData, encoding: .utf8) else {
                throw Abort(.badRequest)
        }

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

        //        return try request.contentCategory(type: typeName).flatMap { category in
        //            return try category.items.query(on: request).paginate(for: request).map { content in
        //                let publicData = content.data.map { return ContentItemPublic($0) }
        //                return Paginated<ContentItemPublic>(page: content.page, data: publicData)
        //            }
        //        }
    }
    
}
