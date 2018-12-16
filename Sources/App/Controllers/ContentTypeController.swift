import Vapor
import Fluent

class ContentTypeController: PigeonController {
    
    override func bootLoggedIn(router: Router) throws {
        router.post(GenericContentCategory.self, at: "/type/create", use: createTypeHandler)
        router.post(GenericContentCategory.self, at: "/type/edit", use: editTypeHandler)
    }
    
    private func createTypeHandler(_ request: Request, category: GenericContentCategory) throws -> Future<Response> {
        category.plural = makeURLSafe(category.plural)

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
        category.plural = makeURLSafe(category.plural)

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

    /// Removes % characters from a string to ensure we can properly escape and unescape it for URLs.
    /// `removingPercentEncoding` fails on any % character that isn't part of a valid escape sequence.
    func makeURLSafe(_ string: String) -> String {
        return string.replacingOccurrences(of: "%", with: "")
    }
    
}

extension Request {
    func allContentTypes() -> Future<[GenericContentCategory]> {
        return GenericContentCategory.query(on: self).all()
    }
}
