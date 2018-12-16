import Vapor
import Crypto
import Authentication

class PigeonController: RouteCollection {
    
    final func boot(router: Router) throws {
        let authMiddleware = User.basicAuthMiddleware(using: BCrypt)
        let userSessionMiddleware = User.authSessionsMiddleware()
        let authRouter = router.grouped(SessionsMiddleware.self)
                               .grouped([authMiddleware,
                                         userSessionMiddleware])
        try bootAuth(router: authRouter)
        
        let redirectMiddleware = RedirectMiddleware<User>.login()
        let loggedInRouter = authRouter.grouped(redirectMiddleware)
        try bootLoggedIn(router: loggedInRouter)

    }
    
    func bootAuth(router: Router) throws { }
    
    func bootLoggedIn(router: Router) throws { }
    
}
