import Vapor

class AppViewController: RouteCollection {
    
    func boot(router: Router) throws {
        router.get("", use: createRootViewHandler)
    }

}

private extension AppViewController {

    func createRootViewHandler(_ request: Request) throws -> Future<View> {
        return try generateVueRoot(for: request)
    }

}
