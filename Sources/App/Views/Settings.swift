import Vapor
import Leaf

struct SettingsPage: Codable {
    var shared: BasePage
    var settings: CMSSettings
}

func settingsView(for req: Request) throws -> Future<View> {
    return try req.base().flatMap { basePage in
        return try req.settings().flatMap { settings in
            let settingsPage = SettingsPage(shared: basePage, settings: settings)
            return try req.view().render("Settings/settings", settingsPage)
        }
    }
}

