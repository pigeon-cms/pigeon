import Vapor

struct Markdown: Content, Equatable {
    var markdown: String
    var html: String
}
