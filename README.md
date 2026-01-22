# FluentGen

A Swift macro that automatically generates Fluent ORM model classes from simple domain model structs.

## Overview

FluentGen eliminates boilerplate by automatically generating Fluent database models from your domain structs:

- **Automatic Model Generation**: Convert structs to Fluent models
- **Type Safety**: Leverage Swift's type system
- **Reduced Boilerplate**: No manual model definitions needed
- **Migration Support**: Automatic schema generation

## Getting Started

### Installation

Add FluentGen to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/mac9sb/fluent-gen", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "FluentGen", package: "fluent-gen")
    ]
)
```

### Usage

Apply the `@FluentModel` macro to your structs:

```swift
import FluentGen

@FluentModel
struct User {
    var id: UUID?
    var name: String
    var email: String
}
```

FluentGen automatically generates the corresponding Fluent model with all necessary methods:

```swift
let user = UserModel(name: "John", email: "john@example.com")
try await user.save(on: database)
```

## Architecture

FluentGen uses Swift Macros to:

1. Analyze your struct definitions
2. Generate Fluent model classes
3. Create migration schemas
4. Provide type-safe database operations

## Development

To contribute to FluentGen:

1. Clone the repository
2. Build the project: `swift build`
3. Run tests: `swift test`
4. Build documentation: `swift package generate-documentation`

## License

See LICENSE file for details.
