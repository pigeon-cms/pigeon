import Vapor
import Leaf

struct IndexPage: Codable {
    var shared: BasePage
}

func generateIndex(for req: Request, privileges: UserPrivileges) throws -> Future<View> {
    return try req.base().flatMap { basePage in
        let indexPage = IndexPage(shared: basePage)
        return try req.view().render("index", indexPage)
    }
}
