import Vapor
import Leaf

func generateLoginPage(for req: Request) throws -> Future<View> {
    let leaf = try req.make(LeafRenderer.self)
    return leaf.render("login")
}
