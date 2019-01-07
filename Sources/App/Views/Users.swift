import Vapor
import Leaf

struct UsersPage: Codable {
    var shared: BasePage
    var currentUser: PublicUser
    var users: [PublicUser]
}

func usersView(for req: Request, currentUser: User, users: [User]) throws -> Future<View> {
    return try req.base().flatMap { basePage in
        let usersPage = UsersPage(shared: basePage,
                                  currentUser: PublicUser(currentUser),
                                  users: users.map { return PublicUser($0) })
        return try req.view().render("Users/users", usersPage)
    }
}

struct CreateUsersPage: Codable {
    var shared: BasePage
}

func createUserView(for req: Request, currentUser: User) throws -> Future<View> {
    guard currentUser.privileges?.rawValue ?? 0 >= UserPrivileges.administrator.rawValue else {
        throw Abort(.forbidden)
    }
    return try req.base(currentPath: "/users").flatMap { basePage in
        return try req.view().render("Users/create-user", CreateUsersPage(shared: basePage))
    }
}
