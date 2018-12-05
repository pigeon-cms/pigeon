import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req -> EventLoopFuture<View> in
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
