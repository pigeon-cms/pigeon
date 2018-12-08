import Vapor
import Leaf

struct UsersPage: Codable {
    var shared: BasePage
    var currentUser: User
    var users: [User]
}

func generateUsers(for req: Request, currentUser: User, users: [User]) throws -> Future<View> {
    let usersPage = try UsersPage(shared: req.base(),
                                  currentUser: currentUser,
                                  users: users)
    return try req.view().render("users", usersPage)
}
