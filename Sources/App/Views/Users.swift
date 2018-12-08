import Vapor
import Leaf

struct UsersPage: Codable {
    var currentUser: User
    var users: [User]
}

func generateUsers(for req: Request, currentUser: User, users: [User]) throws -> Future<View> {
    let usersPage = UsersPage(currentUser: currentUser, users: users)
    return try req.view().render("users", usersPage)
}
