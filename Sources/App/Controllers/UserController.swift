import Vapor
import Crypto
import Fluent

class UserController: RouteCollection {

    func boot(router: Router) throws {
        let group = router.grouped("users")
        group.post(User.self, at: "register", use: registerUserHandler)
    }

}

private extension UserController {
    func registerUserHandler(_ request: Request, newUser: User) -> Future<HTTPResponseStatus> {
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
}
