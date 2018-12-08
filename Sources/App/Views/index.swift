import Vapor
import Leaf

struct IndexPage: Codable {
    var administrator: Bool
    var administrationLinks: [Link]
    var exampleData: String
}

struct Link: Codable {
    var name: String
    var path: String
}

func generateIndex(for req: Request) throws -> Future<View> {
    let leaf = try req.make(LeafRenderer.self)
    
    let administrationLinks = [Link(name: "Users & Roles", path: "/users"),
                               Link(name: "Settings", path: "/settings")]
    let indexPage = IndexPage(administrator: false,
                              administrationLinks: administrationLinks,
                              exampleData: "Hello, world!")
    return leaf.render("index", indexPage)
}
