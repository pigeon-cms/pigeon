import NIO
import Foundation

extension DateFormatter {
    public static var iso8601: DateFormatter {
        return ISO8601.shared.formatter
    }
}

private final class ISO8601 {
    
    /// Thread-specific ISO8601
    private static let thread: ThreadSpecificVariable<ISO8601> = .init()
    
    /// A static ISO8601 helper instance
    static var shared: ISO8601 {
        if let existing = thread.currentValue {
            return existing
        } else {
            let new = ISO8601()
            thread.currentValue = new
            return new
        }
    }
    
    /// The ISO8601 formatter
    let formatter: DateFormatter
    
    /// Creates a new ISO8601 helper
    private init() {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        self.formatter = formatter
    }

}
