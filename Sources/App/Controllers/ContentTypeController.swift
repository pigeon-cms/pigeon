import Vapor
import Fluent

class ContentTypeController: RouteCollection {
    
    func boot(router: Router) throws {
        router.post(GenericContentCategory.self, at: "/type/create", use: createTypeHandler)
    }
    
    private func createTypeHandler(_ request: Request, category: GenericContentCategory) throws -> Future<Response> {
        return GenericContentCategory.query(on: request)
                                     .filter(\.plural == category.plural)
                                     .first().flatMap { existingCategory in
            guard existingCategory == nil else {
                throw Abort(.badRequest, reason: "A type with that name exists")
            }

            return category.save(on: request).map { _ in
                let response = HTTPResponse(status: .created,
                                            headers: HTTPHeaders([("Location", "/types")]))
                return Response(http: response, using: request.sharedContainer)
            }.catchMap { error in
                throw Abort(.internalServerError, reason: error.localizedDescription)
            }
        }
    }
    
}

extension Request {
    func allContentTypes() -> Future<[GenericContentCategory]> {
        return GenericContentCategory.query(on: self).all()
    }
}
