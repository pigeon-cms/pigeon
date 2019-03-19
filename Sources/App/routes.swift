import Vapor
import Authentication

public func routes(_ router: Router) throws {
    try router.register(collection: UserController())

    try router.register(collection: RootViewController())

    try router.register(collection: ContentTypeController())

    try router.register(collection: PostController())

    try router.register(collection: SettingsController())

    try router.register(collection: JSONController())

    try router.register(collection: GraphQLController())
}
