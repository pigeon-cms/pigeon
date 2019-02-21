import Vapor
import Fluent

final class RootViewController: PigeonController {

    override func loginGuardedBoot(router: Router) throws {
        router.get("/", use: rootViewHandler)
    }

}

private extension RootViewController {

    /// TODO: Maybe make the root view a dashboard with post stats, view stats, etc
    func rootViewHandler(_ request: Request) throws -> Future<View> {
        let privileges = try request.privileges()
        return try generateIndex(for: request, privileges: privileges)
    }

}
