import Vapor
import GraphQL

extension SupportedType {
    var graphQL: GraphQLOutputType {
        switch self {
        case .markdown: return SupportedType.graphQLMarkdownType
        case .string: return GraphQLString
        case .int: return GraphQLInt
        case .float: return GraphQLFloat
        case .bool: return GraphQLBoolean
        case .date: return GraphQLString
        case .url: return GraphQLString
        case .array(let type):
            return GraphQLList(type.graphQL)
        }
    }

    private static var graphQLMarkdownType: GraphQLOutputType {
        let fields = [
            "html": GraphQLField(type: GraphQLString, resolve: { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
                guard let markdown = source as? Markdown else {
                    return eventLoopGroup.future(nil)
                }
                return eventLoopGroup.future(markdown.html)
            }),
            "markdown": GraphQLField(type: GraphQLString, resolve: { (source, args, context, eventLoopGroup, info) -> EventLoopFuture<Any?> in
                guard let markdown = source as? Markdown else {
                    return eventLoopGroup.future(nil)
                }
                return eventLoopGroup.future(markdown.markdown)
            })]
        return try! GraphQLObjectType(name: "Markdown",
                                      fields: fields)
    }
}

extension SupportedValue {
    var rawValue: Any {
        switch self {
        case .string(let value): return value as Any
        case .bool(let value): return value as Any
        case .markdown(let value): return value as Any
        default:
            fatalError()
        }
    }
}
