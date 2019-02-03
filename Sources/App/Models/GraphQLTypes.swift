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
