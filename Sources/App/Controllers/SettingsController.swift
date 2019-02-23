import Vapor

final class SettingsController: PigeonController {

    override func loginGuardedBoot(router: Router) throws {
        router.get("/settings", use: settingsViewHandler)
    }

}

private extension SettingsController {

    func settingsViewHandler(_ request: Request) throws -> Future<View> {
        let privileges = try request.privileges()

        guard privileges.rawValue > UserPrivileges.administrator.rawValue else {
        throw Abort(.unauthorized)
        }

        return try usersView(for: request)
    }

}
