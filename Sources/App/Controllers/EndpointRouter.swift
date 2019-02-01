import Vapor
import Pagination

class EndpointController: PigeonController {

    override func authBoot(router: Router) throws {
        router.get(["/json", String.parameter], use: jsonHandler)
        router.get("/graphql") { _ in
            // TODO
            return "graphql"
        }
    }

}

private extension EndpointController {

    func jsonHandler(_ request: Request) throws -> Future<Paginated<ContentItemPublic>> {
        guard let typeName = try request.parameters.next(String.self).removingPercentEncoding else {
            throw Abort(.notFound)
        }

        return try request.contentCategory(type: typeName).flatMap { category in
            return try category.items.query(on: request).paginate(for: request).map { content in
                let publicData = content.data.map { return ContentItemPublic($0) }
                return Paginated<ContentItemPublic>(page: content.page, data: publicData)
            }
        }
    }

}
