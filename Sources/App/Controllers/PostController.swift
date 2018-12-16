import Vapor
import Fluent

class PostController: PigeonController {

    override func loginGuardedBoot(router: Router) throws {
        router.get(["/content", String.parameter], use: postViewController)
        router.get(["/content", String.parameter, "/create"], use: createPostView)
//        router.get(["/content", String.parameter, String.parameter], use: editPostView)
    }

}

private extension PostController {
    
    func postViewController(_ request: Request) throws -> Future<View> {
        guard let typeName = try request.parameters.next(String.self).removingPercentEncoding else {
            throw Abort(.notFound)
        }

        return try request.contentCategory(typePluralName: typeName).flatMap { category in
            return try self.generatePostListView(for: request,
                                                 posts: category.items ?? [],
                                                 plural: category.plural)
        }
    }

    func createPostView(_ request: Request) throws -> Future<View> {
        guard let typeName = try request.parameters.next(String.self).removingPercentEncoding else {
            throw Abort(.notFound)
        }

        return try request.contentCategory(typePluralName: typeName).flatMap { category in
            return try self.generateCreatePostView(for: request,
                                                   category: category)
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

    struct CreatePostPage: Codable {
        var shared: BasePage
        var category: GenericContentCategory
    }

    func generateCreatePostView(for request: Request,
                                category: GenericContentCategory) throws -> Future<View> {
        return try request.base().flatMap { basePage in
            let createPostPage = CreatePostPage(shared: basePage, category: category)
            return try request.view().render("Posts/create-post", createPostPage)
        }
    }
}

extension Request {
    func contentCategory(typePluralName: String) throws -> Future<GenericContentCategory> {
        return GenericContentCategory.query(on: self)
                                     .filter(\.plural == typePluralName)
                                     .first().map { category in
            guard let category = category else {
                throw Abort(.notFound)
            }
            return category
        }
    }
}
