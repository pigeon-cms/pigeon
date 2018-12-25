import Vapor
import Leaf

struct TypesPage: Codable {
    var shared: BasePage
    var currentUser: User
    var contentTypes: [ContentCategory]
}

struct TypePage: Codable {
    var shared: BasePage
    var currentUser: User
    var contentType: ContentCategory
}

func typesView(for req: Request,
               currentUser: User,
               contentTypes: [ContentCategory]) throws -> Future<View> {

    return try req.base().flatMap { basePage in
        let typesPage = TypesPage(shared: basePage,
                                  currentUser: currentUser,
                                  contentTypes: contentTypes)
        return try req.view().render("Types/types", typesPage)
    }

}

func createTypesView(for req: Request,
                     currentUser: User,
                     contentTypes: [ContentCategory]) throws -> Future<View> {

    return try req.base().flatMap { basePage in
        let typesPage = TypesPage(shared: basePage,
                                  currentUser: currentUser,
                                  contentTypes: contentTypes)
        return try req.view().render("Types/create-type", typesPage)
    }

}

func createSingleTypeView(for req: Request,
                          currentUser: User,
                          contentType: ContentCategory) throws -> Future<View> {

    return try req.base().flatMap { basePage in
        let typePage = TypePage(shared: basePage,
                                currentUser: currentUser,
                                contentType: contentType)
        return try req.view().render("Types/edit-type", typePage)
    }
}
