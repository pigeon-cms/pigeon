import Vapor

struct BasePage: Codable {
    var links: [Link]
    var administrationLinks: [Link]
    var user: PublicUser
}

struct Link: Codable {
    var name: String
    var path: String
    var current: Bool
    
    init(name: String, path: String, currentPath: String) {
        self.name = name
        self.path = path
        self.current = currentPath == path
        print(currentPath)
        print(path)
    }
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
    func base(currentPath: String? = nil) throws -> Future<BasePage> {
        let pageAuthorization = try PageAuthorization(privileges: privileges())
        
        /// Provided current path or inferred by URL
        let currentPath = currentPath ?? http.url.path
        
        var administrationLinks = [Link]()
        if pageAuthorization.administratorLinks {
            administrationLinks.append(Link(name: "Content Types", path: "/types",
                                            currentPath: currentPath))
            administrationLinks.append(Link(name: "Users & Roles", path: "/users",
                                            currentPath: currentPath))
            administrationLinks.append(Link(name: "Settings", path: "/settings",
                                            currentPath: currentPath))
        }

        var links = [Link]()

        return ContentCategory.query(on: self).all().map { categories in
            categories.forEach {
                let link = Link(name: $0.plural, path: "/content/\($0.plural)",
                                currentPath: currentPath)
                links.append(link)
            }

            return try BasePage(links: links,
                                administrationLinks: administrationLinks,
                                user: PublicUser(self.user()))
        }

    }
}
