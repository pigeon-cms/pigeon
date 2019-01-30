import Vapor
import Leaf

struct UsersPage: Codable {
    var shared: BasePage
}

func usersView(for req: Request) throws -> Future<View> {
    return try req.base().flatMap { basePage in
        let usersPage = UsersPage(shared: basePage)
        return try req.view().render("Users/users", usersPage)
    }
}

struct CreateUsersPage: Codable {
    var shared: BasePage
}

func createUserView(for req: Request) throws -> Future<View> {
    return try req.base(currentPath: "/users").flatMap { basePage in
        return try req.view().render("Users/create-user", CreateUsersPage(shared: basePage))
    }
}
