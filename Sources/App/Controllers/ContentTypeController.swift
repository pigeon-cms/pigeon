import Vapor

class ContentTypeController: RouteCollection {
    
    func boot(router: Router) throws {
        router.post(GenericContentCategory.self, at: "/type/create", use: createTypeHandler)
    }
    
    private func createTypeHandler(_ request: Request, category: GenericContentCategory) throws -> Future<Response> {
        print(request)
        print(category)
//        var category = category
//        category.items = category.items ?? [UUID: GenericContentItem]()
        return category.save(on: request).map { _ in
            return request.redirect(to: "/types")
        }
    }
    
}

extension Request {
    func allContentTypes() -> Future<[GenericContentCategory]> {
        return GenericContentCategory.query(on: self).all()
    }
}
