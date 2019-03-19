import Vapor
import Fluent
import Pagination

final class JSONController: PigeonController {

    override func authBoot(router: Router) throws {
        router.get(["/json", String.parameter], use: jsonHandler)
    }

}

private extension JSONController {

    func jsonHandler(_ request: Request) throws -> Future<Paginated<ContentItemPublic>> {
        guard let typeName = try request.parameters.next(String.self).removingPercentEncoding else {
            throw Abort(.notFound)
        }
        return try request.jsonEnabled().flatMap { enabled in
            guard enabled else {
                throw Abort(.notFound)
            }
            return try request.defaultPageSize().flatMap { pageSize in
                return try request.contentCategory(type: typeName).flatMap { category in
                    return try category.items.query(on: request).paginate(
                        page: try request.query.get(Int?.self, at: "page") ?? 1,
                        per: try request.query.get(Int?.self, at: "per") ?? pageSize,
                        ContentItem.defaultPageSorts
                    ).map { content in
                        let publicData = content.data.map { return ContentItemPublic($0) }
                        return Paginated<ContentItemPublic>(page: content.response().page, data: publicData)
                    }
                }
            }
        }
    }

}
