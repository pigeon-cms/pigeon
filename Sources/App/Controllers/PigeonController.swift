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
        try authBoot(router: authRouter)

        let redirectMiddleware = RedirectMiddleware<User>.login()
        let loggedInRouter = authRouter.grouped(redirectMiddleware)
        try loginGuardedBoot(router: loggedInRouter)

    }

    /// Routes registered to this router have access to authentication and session middlewares.
    func authBoot(router: Router) throws { }

    /// Routes registered to this router can only be accessed by logged-in users.
    /// Other requests will be redirected to `/login`.
    func loginGuardedBoot(router: Router) throws { }

}
