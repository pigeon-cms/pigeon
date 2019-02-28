import Vapor

final class SettingsController: PigeonController {

    override func loginGuardedBoot(router: Router) throws {
        router.get("/settings", use: settingsViewHandler)
        router.post(CMSSettings.self, at: "/settings", use: settingsUpdateHandler)
    }

}

private extension SettingsController {

    func settingsViewHandler(_ request: Request) throws -> Future<View> {
        let privileges = try request.privileges()

        guard privileges.rawValue > UserPrivileges.administrator.rawValue else {
            throw Abort(.unauthorized)
        }

        return try settingsView(for: request)
    }

    func settingsUpdateHandler(_ request: Request, settings: CMSSettings) throws -> Future<Response> {
        return try SettingsService.shared.save(request, settings: settings).map { status in
            let response = HTTPResponse(status: .accepted)
            return Response(http: response, using: request.sharedContainer)
        }
    }

}
