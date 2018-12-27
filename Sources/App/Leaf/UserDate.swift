import Vapor
import Leaf

/// Formats a floating-point time interval since epoch date to a specified format in
/// the authenticated user's timezone.
///
///     dateFormat(<timeIntervalSinceEpoch>, <dateFormat?>)
///
/// If no date format is supplied, a default will be used. If no user is authenticated,
/// the system timezone will be used.
public final class UserDateFormat: TagRenderer {
    
    public init() {}
    
    public func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        /// Require at least one parameter.
        switch tag.parameters.count {
        case 1, 2, 3: break
        default:
            throw tag.error(
                reason: "Invalid parameter count: \(tag.parameters.count). 1 to 3 required."
            )
        }
        
        let formatter = DateFormatter()
        formatter.timeZone = timeZone(tag.container)
        /// Assume the date is a floating point number
        let date = Date(timeIntervalSince1970: tag.parameters[0].double ?? 0)
        /// Set format as the second param or default to ISO-8601 format.
        if tag.parameters.count == 2, let param = tag.parameters[1].string {
            formatter.dateFormat = param
        } else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }
        
        /// Return formatted date
        return Future.map(on: tag) { .string(formatter.string(from: date)) }
    }
    
    func timeZone(_ container: Container) -> TimeZone {
        guard let user = try? Request(using: container).requireAuthenticated(User.self) else {
            return TimeZone.autoupdatingCurrent
        }
        
        let publicUser = PublicUser(user)
        return publicUser.timeZone
    }
    
}

