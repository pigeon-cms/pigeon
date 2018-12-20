import Vapor

struct ContentField: Content {
    var name: String
    var type: SupportedType
    var value: SupportedValue // .string("A Post Title")
    var required: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(SupportedType.self, forKey: .type)
        required = try container.decode(Bool.self, forKey: .required)
        switch type {
        case .String: value = SupportedValue.string(try? container.decode(String.self, forKey: .value))
        case .Int: value = SupportedValue.int(try? container.decode(Int.self, forKey: .value))
        case .Float: value = SupportedValue.float(try? container.decode(Float.self, forKey: .value))
        case .Bool: value = SupportedValue.bool(try? container.decode(Bool.self, forKey: .value))
        case .Date: value = SupportedValue.date(try? container.decode(Date.self, forKey: .value))
        case .URL: value = SupportedValue.url(try? container.decode(URL.self, forKey: .value))
        case .Array:
            fatalError() // TODO
        }
    }
//    /// RequestEncodable
//    func encode(using container: Container) throws -> EventLoopFuture<Request> {
//        return try value.encode(using: container)
//    }
//
//    /// ResponseEncodable
//    func encode(for req: Request) throws -> EventLoopFuture<Response> {
//        return try value.encode(for: req)
//    }
}
