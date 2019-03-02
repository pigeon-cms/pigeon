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

        if let object = tag.parameters.first?.dictionary {
            var objectString = "{"
            for (key, value) in object {
                objectString.append("""
                    \(escape(string: key, enclosingQuotes: true)): \(escape(string: value.string ?? "null", enclosingQuotes: true)),
                  """)
            }
            objectString.append(" }")
            return tag.container.future(TemplateData.string(objectString))
        }

        guard let string = tag.parameters.first?.string else { return tag.container.future(TemplateData.string("''")) }

        return tag.container.future(TemplateData.string(escape(string: string, enclosingQuotes: enclosingQuotes)))
    }

    private func escape(string: String, enclosingQuotes: Bool) -> String {
        var string = string
        string = string.replacingOccurrences(of: "'", with: "\\'")
        string = string.replacingOccurrences(of: "\n", with: "\\n")

        if enclosingQuotes {
            string = "'\(string)'"
        }

        return string
    }

}
