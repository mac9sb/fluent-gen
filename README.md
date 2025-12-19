# FluentGen

A Swift macro package that automatically generates Fluent ORM model classes from simple domain model structs.

## Overview

FluentGen eliminates code duplication between native Swift applications and Vapor/Hummingbird backend projects by auto-generating Fluent model classes with proper property wrappers from standard Swift structs.

## Features

- **Convention-based mapping**: Automatic camelCase → snake_case conversion, table pluralization
- **Smart property detection**: Automatically maps to appropriate Fluent property wrappers
- **Foreign key support**: Properties ending in "ID" become `@Parent` relationships
- **Timestamp handling**: `createdAt` and `updatedAt` auto-mapped to `@Timestamp`
- **Enum support**: Enums stored as String raw values
- **Bidirectional conversion**: Generates `init(from:)` and `toDTO()` methods

## Installation

Add FluentGen as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://gitea.com/maclong/fluent-gen.git", from: "1.0.0"),
    .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "FluentGen", package: "fluent-gen"),
            .product(name: "Fluent", package: "fluent"),
        ]
    ),
]
```

## Usage

### Basic Example

```swift
import FluentGen

@FluentModel
public struct Venue: Codable, Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public var phoneNumber: String?
    public var tier: VenueTier
    public var createdAt: Date
    public var updatedAt: Date
}
```

This generates:

```swift
final class VenueModel: Model, @unchecked Sendable {
    static let schema = "venues"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @OptionalField(key: "phone_number")
    var phoneNumber: String?

    @Field(key: "tier")
    var tier: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(from dto: Venue) {
        self.id = dto.id
        self.name = dto.name
        self.phoneNumber = dto.phoneNumber
        self.tier = dto.tier.rawValue
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
    }

    func toDTO() -> Venue {
        Venue(
            id: id!,
            name: name,
            phoneNumber: phoneNumber,
            tier: VenueTier(rawValue: tier)!,
            createdAt: createdAt!,
            updatedAt: updatedAt!
        )
    }
}
```

### Foreign Key Example

```swift
@FluentModel
public struct Event: Codable, Identifiable, Sendable {
    public let id: UUID
    public var venueID: UUID  // Becomes @Parent relationship
    public var name: String
    public var status: EventStatus
    public var createdAt: Date
    public var updatedAt: Date
}
```

Generates:

```swift
final class EventModel: Model, @unchecked Sendable {
    static let schema = "events"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "venue_id")
    var venue: VenueModel

    @Field(key: "name")
    var name: String

    @Field(key: "status")
    var status: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(from dto: Event) {
        self.id = dto.id
        self.$venue.id = dto.venueID
        self.name = dto.name
        self.status = dto.status.rawValue
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
    }

    func toDTO() -> Event {
        Event(
            id: id!,
            venueID: $venue.id,
            name: name,
            status: EventStatus(rawValue: status)!,
            createdAt: createdAt!,
            updatedAt: updatedAt!
        )
    }
}
```

## Naming Conventions

### Table Names
Struct names are automatically pluralized and lowercased:
- `Venue` → `"venues"`
- `Event` → `"events"`
- `Category` → `"categories"`

### Column Names
Property names are converted to snake_case:
- `phoneNumber` → `"phone_number"`
- `venueID` → `"venue_id"`
- `createdAt` → `"created_at"`

### Model Class Names
Generated classes are suffixed with "Model":
- `Venue` → `VenueModel`
- `Event` → `EventModel`

## Property Mapping Rules

| Domain Model Property | Fluent Property Wrapper | Column Type |
|-----------------------|-------------------------|-------------|
| `id: UUID` | `@ID(key: .id)` | UUID (primary key) |
| `name: String` | `@Field(key: "name")` | String (required) |
| `phoneNumber: String?` | `@OptionalField(key: "phone_number")` | String (nullable) |
| `venueID: UUID` | `@Parent(key: "venue_id")` | UUID (foreign key) |
| `createdAt: Date` | `@Timestamp(key: "created_at", on: .create)` | Date (auto-set on create) |
| `updatedAt: Date` | `@Timestamp(key: "updated_at", on: .update)` | Date (auto-set on update) |
| `status: EventStatus` (enum) | `@Field(key: "status")` | String (rawValue) |

## Requirements

- Swift 6.2+
- Platforms: iOS 17+, macOS 14+, watchOS 10+, visionOS 1+
- Dependencies: swift-syntax 600.0.0+, fluent 4.9.0+

## How It Works

FluentGen uses Swift's macro system to analyze your struct at compile time and generate a peer class with:

1. **Property Analysis**: Detects property types, optionality, and naming patterns
2. **Convention Mapping**: Applies naming conventions (snake_case, pluralization)
3. **Code Generation**: Creates Fluent model class with appropriate property wrappers
4. **DTO Conversion**: Generates bidirectional conversion methods

The generated code is a peer declaration (sibling to your struct) and is fully type-safe.

## Known Enum Types

For MVP, the following enums are auto-detected and stored as String rawValues:
- `EventStatus`
- `UserRole`
- `VenueTier`
- `TicketType`

## Computed Properties

Computed properties in your domain model are automatically skipped and won't appear in the generated Fluent model.

## License

MIT
