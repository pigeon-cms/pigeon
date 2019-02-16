// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Pigeon",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor-community/pagination.git", from: "1.0.0"),
        .package(url: "https://github.com/GraphQLSwift/GraphQL.git", from: "0.8.0"),
        .package(url: "https://github.com/hallee/CursorPagination", .branch("pagination-coexistence"))
    ],
    targets: [
        .target(name: "App", dependencies: [
            "Vapor",
            "Leaf",
            "Authentication",
            "Pagination",
            "FluentPostgreSQL",
            "GraphQL",
            "CursorPagination"
        ]),
        .target(name: "Run", dependencies: ["App"])
    ]
)
