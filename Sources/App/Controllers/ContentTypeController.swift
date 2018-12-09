import Vapor

extension Request {
    func allContentTypes() -> Future<[GenericContentCategory]> {
        return GenericContentCategory.query(on: self).all()
    }
}
