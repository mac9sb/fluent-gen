#if canImport(Fluent)
@_exported import Fluent
#endif

/// Generates a Fluent model class from a domain model struct.
///
/// Apply this macro to a struct to automatically generate a peer `{Name}Model` class
/// that conforms to Fluent's `Model` protocol with appropriate property wrappers.
///
/// Example:
/// ```swift
/// @FluentModel
/// public struct Venue: Codable, Identifiable, Sendable {
///     public let id: UUID
///     public var name: String
///     public var phoneNumber: String?
///     public var tier: VenueTier
///     public var createdAt: Date
///     public var updatedAt: Date
/// }
///
/// // Generates:
/// final class VenueModel: Model, @unchecked Sendable {
///     static let schema = "venues"
///     @ID(key: .id) var id: UUID?
///     @Field(key: "name") var name: String
///     @OptionalField(key: "phone_number") var phoneNumber: String?
///     @Field(key: "tier") var tier: String
///     @Timestamp(key: "created_at", on: .create) var createdAt: Date?
///     @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
///     init() {}
///     init(from dto: Venue) { ... }
///     func toDTO() -> Venue { ... }
/// }
/// ```
///
/// **Naming Conventions:**
/// - Table name: Pluralized lowercase (Venue → "venues")
/// - Column names: snake_case (phoneNumber → "phone_number")
/// - Model class: {StructName}Model (Venue → VenueModel)
///
/// **Property Mapping:**
/// - `id: UUID` → `@ID(key: .id)`
/// - Required primitive → `@Field(key: "snake_case")`
/// - Optional primitive → `@OptionalField(key: "snake_case")`
/// - `*ID` properties → `@Parent(key: "snake_case")` (e.g., venueID → @Parent var venue: VenueModel)
/// - `createdAt` → `@Timestamp(key: "created_at", on: .create)`
/// - `updatedAt` → `@Timestamp(key: "updated_at", on: .update)`
/// - Enum → Stored as String rawValue
///
/// **Computed properties are automatically skipped.**
@attached(peer, names: suffixed(Model))
public macro FluentModel() =
    #externalMacro(
        module: "FluentGenMacros",
        type: "FluentModelMacro"
    )
