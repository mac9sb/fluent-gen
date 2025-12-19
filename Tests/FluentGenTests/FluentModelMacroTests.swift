import Testing
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
@testable import FluentGenMacros

@Suite("FluentModelMacro Tests")
struct FluentModelMacroTests {
    let testMacros: [String: Macro.Type] = [
        "FluentModel": FluentModelMacro.self
    ]

    @Test("macro expands simple struct with ID and field")
    func simpleStructExpansion() {
        assertMacroExpansion(
            """
            @FluentModel
            struct User {
                var id: UUID?
                var name: String
            }
            """,
            expandedSource: """
            struct User {
                var id: UUID?
                var name: String
            }

            public final class UserModel: Model, @unchecked Sendable {
                public static let schema = "users"

                @ID(key: .id)
                public var id: UUID?

                @Field(key: "name")
                public var name: String

                public init() {}

                public init(from dto: User) {
                    self.id = dto.id
                    self.name = dto.name
                }

                public func toDTO() -> User {
                    User(
                        id: id!,
                        name: name
                    )
                }
            }
            """,
            macros: testMacros
        )
    }

    @Test("macro expands struct with optional fields")
    func optionalFieldsExpansion() {
        assertMacroExpansion(
            """
            @FluentModel
            struct User {
                var id: UUID?
                var name: String
                var phoneNumber: String?
            }
            """,
            expandedSource: """
            struct User {
                var id: UUID?
                var name: String
                var phoneNumber: String?
            }

            public final class UserModel: Model, @unchecked Sendable {
                public static let schema = "users"

                @ID(key: .id)
                public var id: UUID?

                @Field(key: "name")
                public var name: String

                @OptionalField(key: "phone_number")
                public var phoneNumber: String?

                public init() {}

                public init(from dto: User) {
                    self.id = dto.id
                    self.name = dto.name
                    self.phoneNumber = dto.phoneNumber
                }

                public func toDTO() -> User {
                    User(
                        id: id!,
                        name: name,
                        phoneNumber: phoneNumber
                    )
                }
            }
            """,
            macros: testMacros
        )
    }

    @Test("macro expands struct with parent relationship")
    func parentRelationshipExpansion() {
        assertMacroExpansion(
            """
            @FluentModel
            struct Event {
                var id: UUID?
                var title: String
                var venueID: UUID
            }
            """,
            expandedSource: """
            struct Event {
                var id: UUID?
                var title: String
                var venueID: UUID
            }

            public final class EventModel: Model, @unchecked Sendable {
                public static let schema = "events"

                @ID(key: .id)
                public var id: UUID?

                @Field(key: "title")
                public var title: String

                @Parent(key: "venue_id")
                public var venue: VenueModel

                public init() {}

                public init(from dto: Event) {
                    self.id = dto.id
                    self.title = dto.title
                    self.$venue.id = dto.venueID
                }

                public func toDTO() -> Event {
                    Event(
                        id: id!,
                        title: title,
                        venueID: $venue.id
                    )
                }
            }
            """,
            macros: testMacros
        )
    }

    @Test("macro expands struct with timestamps")
    func timestampsExpansion() {
        assertMacroExpansion(
            """
            @FluentModel
            struct User {
                var id: UUID?
                var name: String
                var createdAt: Date?
                var updatedAt: Date?
            }
            """,
            expandedSource: """
            struct User {
                var id: UUID?
                var name: String
                var createdAt: Date?
                var updatedAt: Date?
            }

            public final class UserModel: Model, @unchecked Sendable {
                public static let schema = "users"

                @ID(key: .id)
                public var id: UUID?

                @Field(key: "name")
                public var name: String

                @Timestamp(key: "created_at", on: .create)
                public var createdAt: Date?

                @Timestamp(key: "updated_at", on: .update)
                public var updatedAt: Date?

                public init() {}

                public init(from dto: User) {
                    self.id = dto.id
                    self.name = dto.name
                    self.createdAt = dto.createdAt
                    self.updatedAt = dto.updatedAt
                }

                public func toDTO() -> User {
                    User(
                        id: id!,
                        name: name,
                        createdAt: createdAt!,
                        updatedAt: updatedAt!
                    )
                }
            }
            """,
            macros: testMacros
        )
    }

    @Test("macro expands struct with enum property")
    func enumPropertyExpansion() {
        assertMacroExpansion(
            """
            @FluentModel
            struct Event {
                var id: UUID?
                var title: String
                var status: EventStatus
            }
            """,
            expandedSource: """
            struct Event {
                var id: UUID?
                var title: String
                var status: EventStatus
            }

            public final class EventModel: Model, @unchecked Sendable {
                public static let schema = "events"

                @ID(key: .id)
                public var id: UUID?

                @Field(key: "title")
                public var title: String

                @Field(key: "status")
                public var status: String

                public init() {}

                public init(from dto: Event) {
                    self.id = dto.id
                    self.title = dto.title
                    self.status = dto.status.rawValue
                }

                public func toDTO() -> Event {
                    Event(
                        id: id!,
                        title: title,
                        status: EventStatus(rawValue: status)!
                    )
                }
            }
            """,
            macros: testMacros
        )
    }

    @Test("macro expands complex struct with all property types")
    func complexStructExpansion() {
        assertMacroExpansion(
            """
            @FluentModel
            struct Event {
                var id: UUID?
                var title: String
                var description: String?
                var venueID: UUID
                var status: EventStatus
                var createdAt: Date?
                var updatedAt: Date?
            }
            """,
            expandedSource: """
            struct Event {
                var id: UUID?
                var title: String
                var description: String?
                var venueID: UUID
                var status: EventStatus
                var createdAt: Date?
                var updatedAt: Date?
            }

            public final class EventModel: Model, @unchecked Sendable {
                public static let schema = "events"

                @ID(key: .id)
                public var id: UUID?

                @Field(key: "title")
                public var title: String

                @OptionalField(key: "description")
                public var description: String?

                @Parent(key: "venue_id")
                public var venue: VenueModel

                @Field(key: "status")
                public var status: String

                @Timestamp(key: "created_at", on: .create)
                public var createdAt: Date?

                @Timestamp(key: "updated_at", on: .update)
                public var updatedAt: Date?

                public init() {}

                public init(from dto: Event) {
                    self.id = dto.id
                    self.title = dto.title
                    self.description = dto.description
                    self.$venue.id = dto.venueID
                    self.status = dto.status.rawValue
                    self.createdAt = dto.createdAt
                    self.updatedAt = dto.updatedAt
                }

                public func toDTO() -> Event {
                    Event(
                        id: id!,
                        title: title,
                        description: description,
                        venueID: $venue.id,
                        status: EventStatus(rawValue: status)!,
                        createdAt: createdAt!,
                        updatedAt: updatedAt!
                    )
                }
            }
            """,
            macros: testMacros
        )
    }

    @Test("macro generates correct pluralization for categories")
    func pluralizationCategories() {
        assertMacroExpansion(
            """
            @FluentModel
            struct Category {
                var id: UUID?
                var name: String
            }
            """,
            expandedSource: """
            struct Category {
                var id: UUID?
                var name: String
            }

            public final class CategoryModel: Model, @unchecked Sendable {
                public static let schema = "categories"

                @ID(key: .id)
                public var id: UUID?

                @Field(key: "name")
                public var name: String

                public init() {}

                public init(from dto: Category) {
                    self.id = dto.id
                    self.name = dto.name
                }

                public func toDTO() -> Category {
                    Category(
                        id: id!,
                        name: name
                    )
                }
            }
            """,
            macros: testMacros
        )
    }

    @Test("macro generates correct snake_case for complex property names")
    func snakeCaseConversion() {
        assertMacroExpansion(
            """
            @FluentModel
            struct User {
                var id: UUID?
                var firstName: String
                var lastName: String
                var phoneNumber: String?
            }
            """,
            expandedSource: """
            struct User {
                var id: UUID?
                var firstName: String
                var lastName: String
                var phoneNumber: String?
            }

            public final class UserModel: Model, @unchecked Sendable {
                public static let schema = "users"

                @ID(key: .id)
                public var id: UUID?

                @Field(key: "first_name")
                public var firstName: String

                @Field(key: "last_name")
                public var lastName: String

                @OptionalField(key: "phone_number")
                public var phoneNumber: String?

                public init() {}

                public init(from dto: User) {
                    self.id = dto.id
                    self.firstName = dto.firstName
                    self.lastName = dto.lastName
                    self.phoneNumber = dto.phoneNumber
                }

                public func toDTO() -> User {
                    User(
                        id: id!,
                        firstName: firstName,
                        lastName: lastName,
                        phoneNumber: phoneNumber
                    )
                }
            }
            """,
            macros: testMacros
        )
    }
}
