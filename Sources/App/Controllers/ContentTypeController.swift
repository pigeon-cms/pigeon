import Vapor
import Fluent

class ContentTypeController: PigeonController {

    override func loginGuardedBoot(router: Router) throws {
        router.get("/types", use: typesViewHandler)
        router.get("/types/create", use: createTypesViewHandler)
        router.get("/type", String.parameter, use: typeViewHandler)
        router.post(ContentCategory.self, at: "/type", use: createTypeHandler)
        router.patch(ContentCategory.self, at: "/type", use: editTypeHandler)
    }

    private func typesViewHandler(_ request: Request) throws -> Future<View> {
        let user = try request.user()
        let privileges = try request.privileges()

        guard privileges.rawValue > UserPrivileges.administrator.rawValue else {
            throw Abort(.unauthorized)
        }

        return request.allContentTypes().flatMap { contentTypes in
            if contentTypes.count > 0 {
                return try typesView(for: request, currentUser: user, contentTypes: contentTypes)
            } else {
                throw Abort.redirect(to: "/types/create")
            }
        }
    }

    private func createTypesViewHandler(_ request: Request) throws -> Future<View> {
        let user = try request.user()
        let privileges = try request.privileges()

        guard privileges.rawValue > UserPrivileges.administrator.rawValue else {
            throw Abort(.unauthorized)
        }

        return request.allContentTypes().flatMap { contentTypes in
            return try createTypesView(for: request, currentUser: user, contentTypes: contentTypes)
        }
    }

    private func typeViewHandler(_ request: Request) throws -> Future<View> {
        let user = try request.user()

        guard let typeName = try request.parameters.next(String.self).removingPercentEncoding else {
            throw Abort(.notFound)
        }

        return ContentCategory.query(on: request)
                                     .filter(\.plural == typeName)
                                     .first().flatMap { category in
            guard let category = category else {
                throw Abort(.notFound)
            }
            return try createSingleTypeView(for: request, currentUser: user, contentType: category)
        }
    }

    private func createTypeHandler(_ request: Request, category: ContentCategory) throws -> Future<Response> {
        category.plural = makeURLSafe(category.plural)

        return ContentCategory.query(on: request)
                              .filter(\.plural == category.plural)
                              .first().flatMap { existingCategory in
            guard existingCategory == nil else {
                throw Abort(.badRequest, reason: "A type with that name exists")
            }

            return category.save(on: request).map { _ in
                self.typesModified(request)
                let response = HTTPResponse(status: .created,
                                            headers: HTTPHeaders([("Location", "/types")]))
                return Response(http: response, using: request.sharedContainer)
            }.catchMap { error in
                throw Abort(.internalServerError, reason: error.localizedDescription)
            }
        }
    }

    private func editTypeHandler(_ request: Request, category: ContentCategory) throws -> Future<Response> {
        category.plural = makeURLSafe(category.plural)

        return ContentCategory.query(on: request)
                                     .filter(\.id == category.id)
                                     .first().flatMap { existingCategory in
            guard let existingCategory = existingCategory else {
                throw Abort(.badRequest, reason: "Couldn't locate the type you're trying to edit")
            }

            existingCategory.name = category.name
            existingCategory.plural = category.plural
            existingCategory.template = category.template

            return existingCategory.save(on: request).map { _ in
                self.typesModified(request)
                let response = HTTPResponse(status: .created,
                                            headers: HTTPHeaders([("Location", "/types")]))
                return Response(http: response, using: request.sharedContainer)
                }.catchMap { error in
                    throw Abort(.internalServerError, reason: error.localizedDescription)
            }
        }
    }

    private func typesModified(_ request: Request) {
        request.invalidateGraphQLSchema()
    }

    /// Removes % characters from a string to ensure we can properly escape and unescape it for URLs.
    /// `removingPercentEncoding` fails on any % character that isn't part of a valid escape sequence.
    func makeURLSafe(_ string: String) -> String {
        return string.replacingOccurrences(of: "%", with: "")
    }

}

extension Request {
    func allContentTypes() -> Future<[ContentCategory]> {
        return ContentCategory.query(on: self).all()
    }
}
