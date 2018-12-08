import Vapor

class AppViewController: RouteCollection {

    unowned let userDelegate: UserDelegate
    
    init(userDelegate: UserDelegate) {
        self.userDelegate = userDelegate
    }
    
    func boot(router: Router) throws {
        router.get("", use: createRootViewHandler)
        router.get("/users", use: createUsersViewHandler)
    }

}

private extension AppViewController {

    func createRootViewHandler(_ request: Request) throws -> Future<View> {
        let privileges = try userDelegate.userPrivileges(on: request)
        return try generateIndex(for: request, privileges: privileges)
    }
    
    func createUsersViewHandler(_ request: Request) throws -> Future<View> {
        let user = try userDelegate.authenticatedUser(on: request)
        let privileges = try userDelegate.userPrivileges(on: request)
        
        guard privileges.rawValue > UserPrivileges.administrator.rawValue else {
            throw Abort(.unauthorized)
        }
        
        return try userDelegate.allUsers(on: request).flatMap { users in
            return try generateUsers(for: request, currentUser: user, users: users)
        }
    }

}
