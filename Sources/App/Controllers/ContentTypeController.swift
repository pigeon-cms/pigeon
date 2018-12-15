import Vapor
import Fluent

class ContentTypeController: RouteCollection {
    
    func boot(router: Router) throws {
        router.post(GenericContentCategory.self, at: "/type/create", use: createTypeHandler)
        router.post(GenericContentCategory.self, at: "/type/edit", use: editTypeHandler)
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

    private func editTypeHandler(_ request: Request, category: GenericContentCategory) throws -> Future<Response> {
        return GenericContentCategory.query(on: request)
                                     .filter(\.id == category.id)
                                     .first().flatMap { existingCategory in
            guard let existingCategory = existingCategory else {
                throw Abort(.badRequest, reason: "Couldn't locate the type you're trying to edit")
            }

            existingCategory.name = category.name
            existingCategory.plural = category.plural
            existingCategory.template = category.template

            return existingCategory.save(on: request).map { _ in
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
