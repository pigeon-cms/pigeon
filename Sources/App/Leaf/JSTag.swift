import Vapor
import Leaf

/// Custom leaf tag that escapes Strings for single-quote JavaScript object contexts.
/// For example, `"I'm a String"` outputs to `"I\'m a String"`.
final class JSTag: TagRenderer {
    init() { }

    func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        guard let escaped = tag.parameters.first?.string?.replacingOccurrences(of: "'", with: "\\'") else {
            return tag.container.future(tag.parameters.first ?? TemplateData.null)
        }
        return tag.container.future(TemplateData.string(escaped))
    }
}
