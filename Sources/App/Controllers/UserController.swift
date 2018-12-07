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
        authGroup.post(User.self, at: "register", use: registerUserHandler)
        authGroup.post("login", use: loginUserHandler)
    }

}

private extension UserController {

    func createViewHandler(_ request: Request) throws -> EventLoopFuture<View> {
        let user: User
        do {
            user = try request.requireAuthenticated(User.self)
        } catch {
            return try handleUnauthenticatedUser(request)
        }

        return try generateVueRoot(for: request, with: user)
    }

    /// Handles a request from an unauthenticated user.
    /// If any users exist, this generates the login page. If none have been created yet,
    /// the first-time registration page is generated.
    func handleUnauthenticatedUser(_ request: Request) throws -> EventLoopFuture<View> {
        return User.query(on: request).count().flatMap { count -> EventLoopFuture<View> in
            if count > 0 {
                return try generateLoginPage(for: request)
            } else {
                return try generateFirstTimeRegistrationPage(for: request)
            }
        }
    }
    
    func loginUserHandler(_ request: Request) throws -> EventLoopFuture<Response> {
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

    func registerUserHandler(_ request: Request, newUser: User) throws -> EventLoopFuture<Response> {
        return User.query(on: request).count().flatMap { count -> EventLoopFuture<Response> in
            if count > 0 { // only check authentication if users exist
                // on the first run (no users saved) we should allow registering freely
                guard try request.isAuthenticated(User.self) else {
                    throw Abort(.forbidden)
                }
            }
            // TODO: password, username can't be empty
            return User.query(on: request).filter(\.email == newUser.email).first().flatMap { existingUser in
                guard existingUser == nil else {
                    throw Abort(.badRequest, reason: "A user with this email already exists")
                }
                guard !newUser.email.isEmpty, !newUser.password.isEmpty else {
                    throw Abort(.badRequest, reason: "An email and a password are required")
                }
                
                let digest = try request.make(BCryptDigest.self)
                let hashedPassword = try digest.hash(newUser.password)
                let persistedUser = User(id: nil, name: nil,
                                         email: newUser.email, password: hashedPassword)
                
                return persistedUser.save(on: request).map { _ in
                    return request.redirect(to: "/")
                }
            }
        }
    }

}
