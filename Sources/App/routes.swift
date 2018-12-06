import Vapor
import Authentication

public func routes(_ router: Router) throws {
    let userRouteController = UserController()
    try userRouteController.boot(router: router)

    let authMiddleware = User.basicAuthMiddleware(using: BCrypt)
    let authGroup = router.grouped([authMiddleware]).grouped(SessionsMiddleware.self)

    authGroup.get { req -> EventLoopFuture<View> in
        let user: User
        do {
            user = try req.requireAuthenticated(User.self)
        } catch {
            return try generateLoginPage(for: req)
        }
        
        print(user)
        // TODO: should all this be in middleware?
        return try generateVueRoot(for: req)
    }
    
    router.get("/json") { _ in
        // TODO
        return "json"
    }

    router.get("/graphql") { _ in
        // TODO
        return "graphql"
    }
}
