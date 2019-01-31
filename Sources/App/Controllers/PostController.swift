import Vapor
import Fluent

class PostController: PigeonController {

    override func loginGuardedBoot(router: Router) throws {
        router.get(["/content", String.parameter], use: postViewController)
        router.get(["/content", String.parameter, "/create"], use: createPostView)
        router.get(["/content", String.parameter, UUID.parameter], use: editPostView)
        router.post(ContentItem.self, at: ["/content", String.parameter], use: createPostController)
        router.patch(ContentItem.self, at: ["/content", String.parameter], use: updatePostController)
        router.delete(["/content", String.parameter, UUID.parameter], use: deletePostController)
    }

}

private extension PostController {

    func postViewController(_ request: Request) throws -> Future<View> {
        guard let typeName = try request.parameters.next(String.self).removingPercentEncoding else {
            throw Abort(.notFound)
        }

        return try request.contentCategory(type: typeName).flatMap { category in
            return try category.items.query(on: request).range(..<50).all().flatMap { items in
                let items = items.sorted(by: { $0.created ?? Date.distantPast > $1.created ?? Date.distantPast })
                return try self.generatePostListView(for: request,
                                                     category: category,
                                                     items: items)
            }

        }
    }

    func createPostView(_ request: Request) throws -> Future<View> {
        guard let typeName = try request.parameters.next(String.self).removingPercentEncoding else {
            throw Abort(.notFound)
        }

        return try request.contentCategory(type: typeName).flatMap { category in
            return try self.generateCreatePostView(for: request,
                                                   category: category)
        }
    }
    
    func editPostView(_ request: Request) throws -> Future<View> {
        guard let typeName = try request.parameters.next(String.self).removingPercentEncoding else {
            throw Abort(.notFound)
        }
        
        let id = try request.parameters.next(UUID.self)
        
        return try request.post(type: typeName, post: id).flatMap { (post, category) in
            return try self.generateEditPostView(for: request,
                                                 post: post,
                                                 category: category)
        }
    }

    func createPostController(_ request: Request, item: ContentItem) throws -> Future<Response> {
        item.authors = try [request.user().publicUser]
        return item.save(on: request).flatMap { item in
            return item.category.get(on: request).map { category in
                let response = HTTPResponse(status: .created,
                                            headers: HTTPHeaders([("Location", "/content/\(category.plural)")]))
                return Response(http: response, using: request.sharedContainer)
            }
        }
    }
    
    func updatePostController(_ request: Request, item: ContentItem) throws -> Future<Response> {
        return item.category.get(on: request).flatMap { category in
            guard let postID = item.id else { throw Abort(.notFound) }
            return try request.post(type: category.plural, post: postID).flatMap { (post, category) in
                post.updated = item.updated
                post.content = item.content
                post.authors = item.authors
                return post.save(on: request).map { _ in
                    let response = HTTPResponse(status: .created,
                                                headers: HTTPHeaders([("Location", "/content/\(category.plural)")]))
                    return Response(http: response, using: request.sharedContainer)
                }
            }
        }
    }

    func deletePostController(_ request: Request) throws -> Future<HTTPStatus> {
        let privileges = try request.privileges()

        guard privileges.rawValue > UserPrivileges.administrator.rawValue else {
            throw Abort(.unauthorized)
        }

        guard let typeName = try request.parameters.next(String.self).removingPercentEncoding else {
            throw Abort(.notFound)
        }

        let id = try request.parameters.next(UUID.self)

        return try request.post(type: typeName, post: id).flatMap { (post, _) in
            return post.delete(on: request).map {
                return .ok
            }
        }
    }

    struct PostListPage: Codable {
        var shared: BasePage
        var category: ContentCategory
        var items: [ContentItem]
        // TODO: page number / paging
    }

    func generatePostListView(for request: Request,
                              category: ContentCategory,
                              items: [ContentItem]) throws -> Future<View> {
        return try request.base().flatMap { basePage in
            let postsPage = PostListPage(shared: basePage,
                                         category: category,
                                         items: items)
            return try request.view().render("Posts/posts", postsPage)
        }
    }

    struct CreatePostPage: Codable {
        var shared: BasePage
        var category: ContentCategory
    }

    func generateCreatePostView(for request: Request,
                                category: ContentCategory) throws -> Future<View> {
        return try request.base(currentPath: "/content/" + category.plural).flatMap { basePage in
            let createPostPage = CreatePostPage(shared: basePage, category: category)
            return try request.view().render("Posts/create-post", createPostPage)
        }
    }
    
    struct EditPostPage: Codable {
        var shared: BasePage
        var post: ContentItem
        var category: ContentCategory
    }
    
    func generateEditPostView(for request: Request,
                              post: ContentItem, category: ContentCategory) throws -> Future<View> {
        return try request.base(currentPath: "/content/" + category.plural).flatMap { basePage in
            let editPostPage = EditPostPage(shared: basePage, post: post, category: category)
            return try request.view().render("Posts/edit-post", editPostPage)
        }
    }
}

extension Request {
    func contentCategory(type pluralName: String) throws -> Future<ContentCategory> {
        return ContentCategory.query(on: self)
                                     .filter(\.plural == pluralName)
                                     .first().map { category in
            guard let category = category else {
                throw Abort(.notFound)
            }
            return category
        }
    }
    
    func post(type pluralName: String, post id: UUID) throws -> Future<(ContentItem, ContentCategory)> {
        return try contentCategory(type: pluralName).flatMap { category in
            return try category.items.query(on: self).filter(\.id == id).first().map { post in
                guard let post = post else {
                    throw Abort(.notFound)
                }
                return (post, category)
            }
        }
    }
}
