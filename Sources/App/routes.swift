import Vapor

public func routes(_ router: Router) throws {
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
