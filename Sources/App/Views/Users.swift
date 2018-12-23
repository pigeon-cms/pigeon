import Vapor
import Leaf

struct UsersPage: Codable {
    var shared: BasePage
    var currentUser: PublicUser
    var users: [PublicUser]
}

func generateUsers(for req: Request, currentUser: User, users: [User]) throws -> Future<View> {
    return try req.base().flatMap { basePage in
        let usersPage = UsersPage(shared: basePage,
                                  currentUser: PublicUser(currentUser),
                                  users: users.map { return PublicUser($0) })
        return try req.view().render("Users/users", usersPage)
    }

}
