import GraphQL

extension SupportedType {
    var graphQL: GraphQLOutputType {
        switch self {
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
}

extension SupportedValue {
    var rawValue: Any {
        switch self {
        case .string(let value): return value
        case .bool(let value): return value
        default:
            fatalError()
        }
    }
}
