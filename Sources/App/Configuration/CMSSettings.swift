import Foundation

struct CMSSettings: Codable {
    var jsonEndpointEnabled: Bool
    var graphQLEndpointEnabled: Bool
    var defaultPageSize: Int
    var maxPageSize: Int?

    static let defaults: CMSSettings = {
        return CMSSettings(
            jsonEndpointEnabled: true,
            graphQLEndpointEnabled: true,
            defaultPageSize: 20,
            maxPageSize: nil)
    }()
}


