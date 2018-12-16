import Vapor
import Fluent

class PostController: PigeonController {

    override func loginGuardedBoot(router: Router) throws {
        router.get("/", String.parameter, use: postListController)
    }

}

private extension PostController {
    
    func postListController(_ request: Request) throws -> Future<View> {
        guard let typeName = try request.parameters.next(String.self).removingPercentEncoding else {
            throw Abort(.notFound)
        }
        
        return GenericContentCategory.query(on: request)
                                     .filter(\.plural == typeName)
                                     .first().flatMap { category in
            guard let category = category else {
                throw Abort(.notFound)
            }
            return try self.generatePostListView(for: request,
                                                 posts: category.items ?? [],
                                                 plural: category.plural)
        }
    }
    
    struct PostListPage: Codable {
        var shared: BasePage
        var posts: [GenericContentItem]
        var plural: String
        // TODO: page number / paging
    }
    
    func generatePostListView(for request: Request,
                              posts: [GenericContentItem],
                              plural: String) throws -> Future<View> {
        return try request.base().flatMap { basePage in
            let postsPage = PostListPage(shared: basePage,
                                         posts: posts,
                                         plural: plural)
            return try request.view().render("Posts/posts", postsPage)
        }
    }
}
