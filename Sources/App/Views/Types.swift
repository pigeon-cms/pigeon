import Vapor

struct TypesPage: Codable {
    var shared: BasePage
    var currentUser: User
    var contentTypes: [GenericContentCategory]
}

func generateTypes(for req: Request,
                   currentUser: User,
                   contentTypes: [GenericContentCategory]) throws -> Future<View> {
    let typesPage = TypesPage(shared: try req.base(),
                              currentUser: currentUser,
                              contentTypes: contentTypes)
    return try req.view().render("types", typesPage)
}
