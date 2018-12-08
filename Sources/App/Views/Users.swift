import Vapor
import Leaf

struct UsersPage: Codable {
    var currentUser: User
    var users: [User]
}

func generateUsers(for req: Request, currentUser: User, users: [User]) throws -> Future<View> {
    let leaf = try req.make(LeafRenderer.self)
    
    let usersPage = UsersPage(currentUser: currentUser, users: users)
    return leaf.render("users", usersPage)
}
