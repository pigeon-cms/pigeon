import Vapor
import Authentication

public func routes(_ router: Router) throws {
    let userRouteController = UserController()
    try router.register(collection: userRouteController)

    let rootViewController = RootViewController()
    try router.register(collection: rootViewController)

    let contentController = ContentTypeController()
    try router.register(collection: contentController)

    let postController = PostController()
    try router.register(collection: postController)

    let jsonController = JSONController()
    try router.register(collection: jsonController)

    let graphQLController = GraphQLController()
    try router.register(collection: graphQLController)
}
