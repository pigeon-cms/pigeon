import Vapor
import Leaf

func generateLoginPage(for req: Request) throws -> Future<View> {
    return try req.view().render("login")
}

func generateFirstTimeRegistrationPage(for req: Request) throws -> Future<View> {
    return try req.view().render("register")
}
