import Vapor
import Leaf

struct RootPage: Codable {
    var exampleData: String
}

func generateVueRoot(for req: Request) throws -> Future<View> {
    let leaf = try req.make(LeafRenderer.self)
    let page = RootPage(exampleData: "Hello, world!")
    return leaf.render("index", page)
}
