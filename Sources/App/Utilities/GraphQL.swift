import Foundation
import GraphQL
import Vapor
import NIO

extension Request {
    func graphQLSchema() throws ->  Future<GraphQLSchema> {
        return try PigeonGraphQLSchema.shared.schema(self)
    }

    func invalidateGraphQLSchema() {
        NotificationCenter.default.post(Notification(name: PigeonGraphQLSchema.schemaChangeNotification))
    }
}

private final class PigeonGraphQLSchema {

    /// Thread-specific GraphQL schema
    private static let thread: ThreadSpecificVariable<PigeonGraphQLSchema> = .init()

    static var shared: PigeonGraphQLSchema {
        if let existing = thread.currentValue {
            return existing
        } else {
            let new = PigeonGraphQLSchema()
            new.monitorSchema()
            thread.currentValue = new
            return new
        }
    }
    
    var schema: GraphQLSchema?
    
    func schema(_ request: Request) throws -> Future<GraphQLSchema> {
        if let existing = schema {
            return request.future(existing)
        }
        
        return request.allContentTypes().map { contentTypes in
            var rootFields = [String: GraphQLField]()
            
            for type in contentTypes {
                rootFields[type.plural.camelCase()] = try GraphQLField(
                    type: type.graphQLType(GraphQLPageInfoType),
                    args: type.graphQLPaginationArgs(),
                    resolve: type.rootResolver()
                )
            }

            let schema = try GraphQLSchema(
                query: GraphQLObjectType(
                    name: "RootQueryType",
                    fields: rootFields),
                types: SupportedType.graphQLNamedTypes
            )

            self.schema = schema

            return schema
        }
    }

    static let schemaChangeNotification = Notification.Name("schemaChangeNotification")

    private func monitorSchema() {
        NotificationCenter.default.addObserver(forName: PigeonGraphQLSchema.schemaChangeNotification, object: nil, queue: nil, using: removeSavedSchema)
    }

    private func removeSavedSchema(_ notification: Notification) {
        schema = nil
    }
    
    private init() { }
}
