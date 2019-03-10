import Vapor
import FluentPostgreSQL

enum ContentState: String, Equatable, Content, PostgreSQLEnum, PostgreSQLMigration {
    case draft
    case scheduled
    case published
}
