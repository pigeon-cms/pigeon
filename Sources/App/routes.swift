import Vapor
import Authentication

public func routes(_ router: Router) throws {
    let userRouteController = UserController()
    try router.register(collection: userRouteController)
    
    let contentController = ContentTypeController()
    try router.register(collection: contentController)
    
    let viewController = AppViewController()
    try router.register(collection: viewController)
    
    router.get("/json") { _ in
        // TODO
        return "json"
    }

    router.get("/graphql") { _ in
        // TODO
        return "graphql"
    }
}
