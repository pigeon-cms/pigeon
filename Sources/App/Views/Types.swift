import Vapor

struct TypesPage: Codable {
    var shared: BasePage
    var currentUser: User
    var contentTypes: [GenericContentCategory]
}

func typesView(for req: Request,
               currentUser: User,
               contentTypes: [GenericContentCategory]) throws -> Future<View> {
    
    let typesPage = TypesPage(shared: try req.base(),
                              currentUser: currentUser,
                              contentTypes: contentTypes)
    return try req.view().render("types", typesPage)
}

func createTypesView(for req: Request,
                     currentUser: User,
                     contentTypes: [GenericContentCategory]) throws -> Future<View> {

    let typesPage = TypesPage(shared: try req.base(),
                              currentUser: currentUser,
                              contentTypes: contentTypes)
    return try req.view().render("create-types", typesPage)
}

func createSingleTypeView(for req: Request,
                          currentUser: User,
                          contentType: GenericContentCategory) throws -> Future<View> {

    let typesPage = TypesPage(shared: try req.base(),
                              currentUser: currentUser,
                              contentTypes: [contentType])
    return try req.view().render("types", typesPage)
}
