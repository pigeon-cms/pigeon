import Vapor

class AppViewController: RouteCollection {
    
    func boot(router: Router) throws {
        router.get("", use: createRootViewHandler)
        router.get("/users", use: createUsersViewHandler)
    }

}

private extension AppViewController {

    func createRootViewHandler(_ request: Request) throws -> Future<View> {
        let privileges = try request.privileges()
        return try generateIndex(for: request, privileges: privileges)
    }
    
    func createUsersViewHandler(_ request: Request) throws -> Future<View> {
        let user = try request.user()
        let privileges = try request.privileges()
        
        guard privileges.rawValue > UserPrivileges.administrator.rawValue else {
            throw Abort(.unauthorized)
        }
        
        return try request.allUsers().flatMap { users in
            return try generateUsers(for: request, currentUser: user, users: users)
        }
    }

}
