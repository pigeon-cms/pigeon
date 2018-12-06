import Vapor
import Authentication

public func routes(_ router: Router) throws {
    let userRouteController = UserController()
    try userRouteController.boot(router: router)
    
    router.get("/json") { _ in
        // TODO
        return "json"
    }

    router.get("/graphql") { _ in
        // TODO
        return "graphql"
    }
}
