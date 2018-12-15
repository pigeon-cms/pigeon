import Vapor

struct BasePage: Codable {
    var links: [Link]
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
    func base() throws -> Future<BasePage> {
        let pageAuthorization = try PageAuthorization(privileges: privileges())

        var administrationLinks = [Link]()
        if pageAuthorization.administratorLinks {
            administrationLinks.append(Link(name: "Content Types", path: "/types"))
            administrationLinks.append(Link(name: "Users & Roles", path: "/users"))
            administrationLinks.append(Link(name: "Settings", path: "/settings"))
        }

        var links = [Link]()

        return GenericContentCategory.query(on: self).all().map { categories in
            categories.forEach {
                let link = Link(name: $0.plural, path: "/posts/\($0.plural)")
                links.append(link)
            }

            return BasePage(links: links, administrationLinks: administrationLinks)
        }
        
    }
}
