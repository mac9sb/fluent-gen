import Testing
import SwiftSyntax
@testable import FluentGenMacros

@Suite("CodeGenerator Tests")
struct CodeGeneratorTests {
    let generator = CodeGenerator()

    @Test("generateFluentModel creates basic model class")
    func basicModelGeneration() throws {
        let properties = [
            PropertyInfo(
                name: "id",
                columnName: "id",
                kind: .id(type: "UUID"),
                isOptional: true,
                originalType: "UUID?"
            ),
            PropertyInfo(
                name: "name",
                columnName: "name",
                kind: .field(type: "String"),
                isOptional: false,
                originalType: "String"
            )
        ]

        let decl = try generator.generateFluentModel(structName: "User", properties: properties)
        let code = decl.description

        #expect(code.contains("public final class UserModel: Model"))
        #expect(code.contains("public static let schema = \"users\""))
        #expect(code.contains("@unchecked Sendable"))
    }

    @Test("generateFluentModel creates ID field")
    func idFieldGeneration() throws {
        let properties = [
            PropertyInfo(
                name: "id",
                columnName: "id",
                kind: .id(type: "UUID"),
                isOptional: true,
                originalType: "UUID?"
            )
        ]

        let decl = try generator.generateFluentModel(structName: "User", properties: properties)
        let code = decl.description

        #expect(code.contains("@ID(key: .id)"))
        #expect(code.contains("public var id: UUID?"))
    }

    @Test("generateFluentModel creates required fields")
    func requiredFieldGeneration() throws {
        let properties = [
            PropertyInfo(
                name: "name",
                columnName: "name",
                kind: .field(type: "String"),
                isOptional: false,
                originalType: "String"
            ),
            PropertyInfo(
                name: "age",
                columnName: "age",
                kind: .field(type: "Int"),
                isOptional: false,
                originalType: "Int"
            )
        ]

        let decl = try generator.generateFluentModel(structName: "User", properties: properties)
        let code = decl.description

        #expect(code.contains("@Field(key: \"name\")"))
        #expect(code.contains("public var name: String"))
        #expect(code.contains("@Field(key: \"age\")"))
        #expect(code.contains("public var age: Int"))
    }

    @Test("generateFluentModel creates optional fields")
    func optionalFieldGeneration() throws {
        let properties = [
            PropertyInfo(
                name: "phoneNumber",
                columnName: "phone_number",
                kind: .optionalField(type: "String"),
                isOptional: true,
                originalType: "String?"
            )
        ]

        let decl = try generator.generateFluentModel(structName: "User", properties: properties)
        let code = decl.description

        #expect(code.contains("@OptionalField(key: \"phone_number\")"))
        #expect(code.contains("public var phoneNumber: String?"))
    }

    @Test("generateFluentModel creates parent relationships")
    func parentRelationshipGeneration() throws {
        let properties = [
            PropertyInfo(
                name: "venueID",
                columnName: "venue_id",
                kind: .parent(entityName: "venue"),
                isOptional: false,
                originalType: "UUID"
            )
        ]

        let decl = try generator.generateFluentModel(structName: "Event", properties: properties)
        let code = decl.description

        #expect(code.contains("@Parent(key: \"venue_id\")"))
        #expect(code.contains("public var venue: VenueModel"))
    }

    @Test("generateFluentModel creates timestamp fields")
    func timestampFieldGeneration() throws {
        let properties = [
            PropertyInfo(
                name: "createdAt",
                columnName: "created_at",
                kind: .timestampCreate,
                isOptional: true,
                originalType: "Date?"
            ),
            PropertyInfo(
                name: "updatedAt",
                columnName: "updated_at",
                kind: .timestampUpdate,
                isOptional: true,
                originalType: "Date?"
            )
        ]

        let decl = try generator.generateFluentModel(structName: "User", properties: properties)
        let code = decl.description

        #expect(code.contains("@Timestamp(key: \"created_at\", on: .create)"))
        #expect(code.contains("public var createdAt: Date?"))
        #expect(code.contains("@Timestamp(key: \"updated_at\", on: .update)"))
        #expect(code.contains("public var updatedAt: Date?"))
    }

    @Test("generateFluentModel creates enum fields")
    func enumFieldGeneration() throws {
        let properties = [
            PropertyInfo(
                name: "status",
                columnName: "status",
                kind: .enum(type: "EventStatus", underlyingType: "String"),
                isOptional: false,
                originalType: "EventStatus"
            ),
            PropertyInfo(
                name: "role",
                columnName: "role",
                kind: .enum(type: "UserRole", underlyingType: "String"),
                isOptional: true,
                originalType: "UserRole?"
            )
        ]

        let decl = try generator.generateFluentModel(structName: "User", properties: properties)
        let code = decl.description

        #expect(code.contains("@Field(key: \"status\")"))
        #expect(code.contains("public var status: String"))
        #expect(code.contains("@OptionalField(key: \"role\")"))
        #expect(code.contains("public var role: String?"))
    }

    @Test("generateFluentModel creates empty initializer")
    func emptyInitializerGeneration() throws {
        let properties = [
            PropertyInfo(
                name: "id",
                columnName: "id",
                kind: .id(type: "UUID"),
                isOptional: true,
                originalType: "UUID?"
            )
        ]

        let decl = try generator.generateFluentModel(structName: "User", properties: properties)
        let code = decl.description

        #expect(code.contains("public init() {}"))
    }

    @Test("generateFluentModel creates from DTO initializer")
    func fromDTOInitializerGeneration() throws {
        let properties = [
            PropertyInfo(
                name: "id",
                columnName: "id",
                kind: .id(type: "UUID"),
                isOptional: true,
                originalType: "UUID?"
            ),
            PropertyInfo(
                name: "name",
                columnName: "name",
                kind: .field(type: "String"),
                isOptional: false,
                originalType: "String"
            ),
            PropertyInfo(
                name: "venueID",
                columnName: "venue_id",
                kind: .parent(entityName: "venue"),
                isOptional: false,
                originalType: "UUID"
            ),
            PropertyInfo(
                name: "status",
                columnName: "status",
                kind: .enum(type: "EventStatus", underlyingType: "String"),
                isOptional: false,
                originalType: "EventStatus"
            )
        ]

        let decl = try generator.generateFluentModel(structName: "Event", properties: properties)
        let code = decl.description

        #expect(code.contains("public init(from dto: Event)"))
        #expect(code.contains("self.id = dto.id"))
        #expect(code.contains("self.name = dto.name"))
        #expect(code.contains("self.$venue.id = dto.venueID"))
        #expect(code.contains("self.status = dto.status.rawValue"))
    }

    @Test("generateFluentModel creates toDTO method")
    func toDTOMethodGeneration() throws {
        let properties = [
            PropertyInfo(
                name: "id",
                columnName: "id",
                kind: .id(type: "UUID"),
                isOptional: true,
                originalType: "UUID?"
            ),
            PropertyInfo(
                name: "name",
                columnName: "name",
                kind: .field(type: "String"),
                isOptional: false,
                originalType: "String"
            ),
            PropertyInfo(
                name: "phoneNumber",
                columnName: "phone_number",
                kind: .optionalField(type: "String"),
                isOptional: true,
                originalType: "String?"
            ),
            PropertyInfo(
                name: "venueID",
                columnName: "venue_id",
                kind: .parent(entityName: "venue"),
                isOptional: false,
                originalType: "UUID"
            ),
            PropertyInfo(
                name: "createdAt",
                columnName: "created_at",
                kind: .timestampCreate,
                isOptional: true,
                originalType: "Date?"
            )
        ]

        let decl = try generator.generateFluentModel(structName: "Event", properties: properties)
        let code = decl.description

        #expect(code.contains("public func toDTO() -> Event"))
        #expect(code.contains("Event("))
        #expect(code.contains("id: id!"))
        #expect(code.contains("name: name"))
        #expect(code.contains("phoneNumber: phoneNumber"))
        #expect(code.contains("venueID: $venue.id"))
        #expect(code.contains("createdAt: createdAt!"))
    }

    @Test("generateFluentModel generates correct table name")
    func tableNameGeneration() throws {
        let properties = [
            PropertyInfo(
                name: "id",
                columnName: "id",
                kind: .id(type: "UUID"),
                isOptional: true,
                originalType: "UUID?"
            )
        ]

        let decl = try generator.generateFluentModel(structName: "Category", properties: properties)
        let code = decl.description

        #expect(code.contains("public static let schema = \"categories\""))
    }

    @Test("generateFluentModel handles complex model with all property types")
    func complexModelGeneration() throws {
        let properties = [
            PropertyInfo(
                name: "id",
                columnName: "id",
                kind: .id(type: "UUID"),
                isOptional: true,
                originalType: "UUID?"
            ),
            PropertyInfo(
                name: "title",
                columnName: "title",
                kind: .field(type: "String"),
                isOptional: false,
                originalType: "String"
            ),
            PropertyInfo(
                name: "description",
                columnName: "description",
                kind: .optionalField(type: "String"),
                isOptional: true,
                originalType: "String?"
            ),
            PropertyInfo(
                name: "venueID",
                columnName: "venue_id",
                kind: .parent(entityName: "venue"),
                isOptional: false,
                originalType: "UUID"
            ),
            PropertyInfo(
                name: "status",
                columnName: "status",
                kind: .enum(type: "EventStatus", underlyingType: "String"),
                isOptional: false,
                originalType: "EventStatus"
            ),
            PropertyInfo(
                name: "createdAt",
                columnName: "created_at",
                kind: .timestampCreate,
                isOptional: true,
                originalType: "Date?"
            ),
            PropertyInfo(
                name: "updatedAt",
                columnName: "updated_at",
                kind: .timestampUpdate,
                isOptional: true,
                originalType: "Date?"
            )
        ]

        let decl = try generator.generateFluentModel(structName: "Event", properties: properties)
        let code = decl.description

        // Verify class structure
        #expect(code.contains("public final class EventModel: Model"))
        #expect(code.contains("public static let schema = \"events\""))

        // Verify all property wrappers are present
        #expect(code.contains("@ID"))
        #expect(code.contains("@Field"))
        #expect(code.contains("@OptionalField"))
        #expect(code.contains("@Parent"))
        #expect(code.contains("@Timestamp"))

        // Verify initializers
        #expect(code.contains("public init() {}"))
        #expect(code.contains("public init(from dto: Event)"))
        #expect(code.contains("public func toDTO() -> Event"))
    }
}
