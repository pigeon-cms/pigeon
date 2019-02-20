import Foundation

enum Endpoint: String, Codable, CaseIterable {
    case json
    case graphQL
}

struct Settings: Codable {
    var enabledEndpoints: [Endpoint: Bool]
    var defaultPageSize: Int
    var maxPageSize: Int?

    static let defaults: Settings = {
        return Settings(
            enabledEndpoints: [.json: true, .graphQL: true],
            defaultPageSize: 20,
            maxPageSize: nil)
    }()
}


