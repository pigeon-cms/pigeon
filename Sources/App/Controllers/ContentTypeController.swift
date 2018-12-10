import Vapor

class ContentTypeController: RouteCollection {
    
    func boot(router: Router) throws {
        router.post([GenericContentField].self, at: "/type/create", use: createTypeHandler)
    }
    
    private func createTypeHandler(_ request: Request, category: [GenericContentField]) throws -> Future<Response> {
        print(request)
        print(category)
        throw Abort.redirect(to: "/")
    }
    
}

extension Request {
    func allContentTypes() -> Future<[GenericContentCategory]> {
        return GenericContentCategory.query(on: self).all()
    }
}
