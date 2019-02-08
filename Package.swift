// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Pigeon",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor-community/pagination.git", from: "1.0.0"),
        .package(url: "https://github.com/GraphQLSwift/Graphiti.git", from: "0.7.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "Leaf", "Authentication", "Pagination",
                                            "FluentPostgreSQL", "Graphiti"]),
        .target(name: "Run", dependencies: ["App"])
    ]
)
