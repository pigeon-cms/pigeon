import Vapor

protocol UserDelegate: AnyObject {
    func authenticatedUser(on request: Request) throws -> User
    func userPrivileges(on request: Request) throws -> UserPrivileges
    func allUsers(on request: Request) throws -> Future<[User]>
}
