import Vapor

struct BasePage: Codable {
    var administrationLinks: [Link]
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

extension Request {
    func base() throws -> BasePage {
        let pageAuthorization = try PageAuthorization(privileges: privileges())
        var administrationLinks = [Link]()
        if pageAuthorization.administratorLinks {
            administrationLinks.append(Link(name: "Users & Roles", path: "/users"))
            administrationLinks.append(Link(name: "Settings", path: "/settings"))
        }
        
        return BasePage(administrationLinks: administrationLinks)
    }
}
