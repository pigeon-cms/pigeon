import Vapor
import Authentication

public func routes(_ router: Router) throws {
    let userRouteController = UserController()
    try userRouteController.boot(router: router)

    let authMiddleware = User.basicAuthMiddleware(using: BCrypt)
    let userSessionMiddleware = User.authSessionsMiddleware()
    let authGroup = router.grouped(SessionsMiddleware.self)
                          .grouped([authMiddleware, userSessionMiddleware])    

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
    
    authGroup.get("login") { req -> Future<String> in
        return User.find(UUID(uuidString: "C8A090A2-E6FA-4D45-9644-16F46B7CCF92")!,
                         on: req).map { user in
            guard let user = user else {
                throw Abort(.badRequest)
            }
            try req.authenticate(user)
            return "Logged in!"
        }
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
