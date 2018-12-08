import Vapor
import Leaf

struct IndexPage: Codable {
    var administrationLinks: [Link]
    var exampleData: String
}

struct Link: Codable {
    var name: String
    var path: String
}

struct PageAuthorization: Codable {
    var editContentTypes: Bool
    var administratorLinks: Bool
    
    init(privileges: UserPrivileges?) {
        let privileges = privileges ?? .user
        editContentTypes = privileges.rawValue >= UserPrivileges.editor.rawValue
        administratorLinks = privileges.rawValue >= UserPrivileges.administrator.rawValue
    }
}

func generateIndex(for req: Request, privileges: UserPrivileges) throws -> Future<View> {
    let leaf = try req.make(LeafRenderer.self)
    
    let pageAuthorization = PageAuthorization(privileges: privileges)
    var administrationLinks = [Link]()
    if pageAuthorization.administratorLinks {
        administrationLinks.append(Link(name: "Users & Roles", path: "/users"))
        administrationLinks.append(Link(name: "Settings", path: "/settings"))
    }
    
    let indexPage = IndexPage(administrationLinks: administrationLinks,
                              exampleData: "Hello, world!")
    return leaf.render("index", indexPage)
}
