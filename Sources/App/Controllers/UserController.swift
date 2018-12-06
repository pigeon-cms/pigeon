import Vapor
import Crypto
import Fluent

class UserController: RouteCollection {

    func boot(router: Router) throws {
        let authMiddleware = User.basicAuthMiddleware(using: BCrypt)
        let userSessionMiddleware = User.authSessionsMiddleware()
        let authGroup = router.grouped(SessionsMiddleware.self)
                              .grouped([authMiddleware, userSessionMiddleware])
        
        authGroup.get("", use: createViewHandler)
        authGroup.get("login", use: forceLoginTest) // TODO: remove! just for testing
        authGroup.post(User.self, at: "register", use: registerUserHandler)
        authGroup.post("login", use: attemptUserLogin)
    }

}

private extension UserController {
    func createViewHandler(_ request: Request) throws -> EventLoopFuture<View> {
        let user: User
        do {
            user = try request.requireAuthenticated(User.self)
        } catch {
            return try generateLoginPage(for: request)
        }
        
        print(user)
        return try generateVueRoot(for: request)
    }
    
    func attemptUserLogin(_ request: Request) throws -> EventLoopFuture<Response> {
        return try request.content.decode(User.self).flatMap { user in
            return User.authenticate(
                using: BasicAuthorization.init(username: user.email,
                                               password: user.password),
                verifier: try request.make(BCryptDigest.self),
                on: request
            ).map { user in
                guard let user = user else {
                    return request.redirect(to: "/")
                }
                try request.authenticate(user)
                return request.redirect(to: "/")
            }
        }
    }

    func registerUserHandler(_ request: Request, newUser: User) -> EventLoopFuture<HTTPResponseStatus> {
        return User.query(on: request).filter(\.email == newUser.email).first().flatMap { existingUser in
            guard existingUser == nil else {
                throw Abort(.badRequest, reason: "A user with this email already exists" , identifier: nil)
            }

            let digest = try request.make(BCryptDigest.self)
            let hashedPassword = try digest.hash(newUser.password)
            let persistedUser = User(id: nil, email: newUser.email, password: hashedPassword)

            return persistedUser.save(on: request).transform(to: .created)
        }
    }
    
    func forceLoginTest(_ request: Request) throws -> EventLoopFuture<String> {
        return User.find(UUID(uuidString: "C8A090A2-E6FA-4D45-9644-16F46B7CCF92")!,
                         on: request).map { user in
            guard let user = user else {
                throw Abort(.badRequest)
            }
            try request.authenticate(user)
            return "Logged in!"
        }
    }
}
