import Vapor
import Leaf

/// Formats a floating-point time interval since epoch date to a specified format in
/// the authenticated user's timezone.
///
///     dateTimeZoneFormat(<timeIntervalSinceEpoch>, <timeZoneName?>, <dateFormat?>)
///
/// If no date format is supplied, a default will be used. If no time zone name is given,
/// the system timezone will be used.
public final class DateTimeZoneFormat: TagRenderer {
    
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
        /// Assume the date is a floating point number
        let date = Date(timeIntervalSince1970: tag.parameters[0].double ?? 0)
        /// TimeZone from the given name, fallback to system TimeZone if name is invalid
        if tag.parameters.count >= 2, let param = tag.parameters[1].string {
            formatter.timeZone = timeZone(param)
        }
        /// Set format as the second param or default to ISO-8601 format.
        if tag.parameters.count == 3, let param = tag.parameters[2].string {
            formatter.dateFormat = param
        } else {
            formatter.dateFormat = "y-MM-dd HH:mm:ss"
        }
        
        /// Return formatted date
        return Future.map(on: tag) { .string(formatter.string(from: date)) }
    }
    
    func timeZone(_ name: String?) -> TimeZone {
        return TimeZone(identifier: name ?? "") ?? TimeZone.autoupdatingCurrent
    }
    
}

