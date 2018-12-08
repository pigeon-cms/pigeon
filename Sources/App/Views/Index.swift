import Vapor
import Leaf

struct IndexPage: Codable {
    var shared: BasePage
}

func generateIndex(for req: Request, privileges: UserPrivileges) throws -> Future<View> {
    let indexPage = try IndexPage(shared: req.base())
    return try req.view().render("index", indexPage)
}
