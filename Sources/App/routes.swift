import Vapor
import Authentication

public func routes(_ router: Router) throws {
    let userRouteController = UserController()
    try router.register(collection: userRouteController)

    let contentController = ContentTypeController()
    try router.register(collection: contentController)
    
    let postController = PostController()
    try router.register(collection: postController)

    let viewController = AppViewController()
    try router.register(collection: viewController)

    let endpointController = EndpointController()
    try router.register(collection: endpointController)
