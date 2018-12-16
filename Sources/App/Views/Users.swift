import Vapor
import Leaf

struct UsersPage: Codable {
    var shared: BasePage
    var currentUser: User
    var users: [User]
}

func generateUsers(for req: Request, currentUser: User, users: [User]) throws -> Future<View> {
    return try req.base().flatMap { basePage in
        let usersPage = UsersPage(shared: basePage,
                                  currentUser: currentUser,
                                  users: users)
        return try req.view().render("Users/users", usersPage)
    }

}
