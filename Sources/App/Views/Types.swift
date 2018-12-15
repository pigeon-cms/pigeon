import Vapor
import Leaf

struct TypesPage: Codable {
    var shared: BasePage
    var currentUser: User
    var contentTypes: [GenericContentCategory]
}

struct TypePage: Codable {
    var shared: BasePage
    var currentUser: User
    var contentType: GenericContentCategory
}

func typesView(for req: Request,
               currentUser: User,
               contentTypes: [GenericContentCategory]) throws -> Future<View> {
    
    let typesPage = TypesPage(shared: try req.base(),
                              currentUser: currentUser,
                              contentTypes: contentTypes)
    return try req.view().render("Types/types", typesPage)
}

func createTypesView(for req: Request,
                     currentUser: User,
                     contentTypes: [GenericContentCategory]) throws -> Future<View> {

    let typesPage = TypesPage(shared: try req.base(),
                              currentUser: currentUser,
                              contentTypes: contentTypes)
    return try req.view().render("Types/create-types", typesPage)
}

func createSingleTypeView(for req: Request,
                          currentUser: User,
                          contentType: GenericContentCategory) throws -> Future<View> {

    let typePage = TypePage(shared: try req.base(),
                            currentUser: currentUser,
                            contentType: contentType)
    return try req.view().render("Types/type", typePage)
}
