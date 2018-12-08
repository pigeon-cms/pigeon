import Vapor

class AppViewController: RouteCollection {
    
    func boot(router: Router) throws {
        router.get("", use: createRootViewHandler)
    }

}

private extension AppViewController {

    func createRootViewHandler(_ request: Request) throws -> Future<View> {
        let privileges = try UserController.userPrivileges(on: request)
        return try generateIndex(for: request, privileges: privileges)
    }

}
