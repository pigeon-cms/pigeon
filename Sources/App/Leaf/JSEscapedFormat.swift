import Vapor
import Leaf

/// Custom leaf tag that escapes Strings for JavaScript object contexts.
/// For example, `"I'm a String"` outputs to `"'I\'m a String'"` (with enclosing single-quotes).
/// Leaves boolean objects without single-quotes.
public final class JSEscapedFormat: TagRenderer {

    public init() { }

    public func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        var enclosingQuotes = true
        if tag.parameters.first?.bool != nil {
            enclosingQuotes = false
        }

        guard var escaped = tag.parameters.first?.string?.replacingOccurrences(of: "'", with: "\\'") else {
            return tag.container.future(TemplateData.string("''"))
        }

        if enclosingQuotes {
            escaped = "'\(escaped)'"
        }

        return tag.container.future(TemplateData.string(escaped))
    }

}
