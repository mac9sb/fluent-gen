import SwiftParser
import SwiftSyntax
import Testing

@testable import FluentGenMacros

@Suite("PropertyAnalyzer Tests")
struct PropertyAnalyzerTests {
    let analyzer = PropertyAnalyzer()

    @Test("analyze detects ID property")
    func idProperty() throws {
        let source = """
            struct User {
                var id: UUID?
            }
            """

        let parsed = Parser.parse(source: source)
        let structDecl = parsed.statements.first?.item.as(StructDeclSyntax.self)
        let varDecl = structDecl?.memberBlock.members.first?.decl.as(VariableDeclSyntax.self)

        let info = try analyzer.analyze(varDecl, in: structDecl!)

        #expect(info != nil)
        #expect(info?.name == "id")
        #expect(info?.columnName == "id")
        #expect(info?.isOptional == true)
        if case .id(let type) = info?.kind {
            #expect(type == "UUID")
        } else {
            Issue.record("Expected .id property kind")
        }
    }

    @Test("analyze detects required field")
    func requiredField() throws {
        let source = """
            struct User {
                var name: String
            }
            """

        let parsed = Parser.parse(source: source)
        let structDecl = parsed.statements.first?.item.as(StructDeclSyntax.self)
        let varDecl = structDecl?.memberBlock.members.first?.decl.as(VariableDeclSyntax.self)

        let info = try analyzer.analyze(varDecl, in: structDecl!)

        #expect(info != nil)
        #expect(info?.name == "name")
        #expect(info?.columnName == "name")
        #expect(info?.isOptional == false)
        if case .field(let type) = info?.kind {
            #expect(type == "String")
        } else {
            Issue.record("Expected .field property kind")
        }
    }

    @Test("analyze detects optional field")
    func optionalField() throws {
        let source = """
            struct User {
                var phoneNumber: String?
            }
            """

        let parsed = Parser.parse(source: source)
        let structDecl = parsed.statements.first?.item.as(StructDeclSyntax.self)
        let varDecl = structDecl?.memberBlock.members.first?.decl.as(VariableDeclSyntax.self)

        let info = try analyzer.analyze(varDecl, in: structDecl!)

        #expect(info != nil)
        #expect(info?.name == "phoneNumber")
        #expect(info?.columnName == "phone_number")
        #expect(info?.isOptional == true)
        if case .optionalField(let type) = info?.kind {
            #expect(type == "String")
        } else {
            Issue.record("Expected .optionalField property kind")
        }
    }

    @Test("analyze detects parent relationship")
    func parentRelationship() throws {
        let source = """
            struct Event {
                var venueID: UUID
            }
            """

        let parsed = Parser.parse(source: source)
        let structDecl = parsed.statements.first?.item.as(StructDeclSyntax.self)
        let varDecl = structDecl?.memberBlock.members.first?.decl.as(VariableDeclSyntax.self)

        let info = try analyzer.analyze(varDecl, in: structDecl!)

        #expect(info != nil)
        #expect(info?.name == "venueID")
        #expect(info?.columnName == "venue_id")
        if case .parent(let entityName) = info?.kind {
            #expect(entityName == "venue")
        } else {
            Issue.record("Expected .parent property kind")
        }
    }

    @Test("analyze detects createdAt timestamp")
    func createdAtTimestamp() throws {
        let source = """
            struct User {
                var createdAt: Date?
            }
            """

        let parsed = Parser.parse(source: source)
        let structDecl = parsed.statements.first?.item.as(StructDeclSyntax.self)
        let varDecl = structDecl?.memberBlock.members.first?.decl.as(VariableDeclSyntax.self)

        let info = try analyzer.analyze(varDecl, in: structDecl!)

        #expect(info != nil)
        #expect(info?.name == "createdAt")
        #expect(info?.columnName == "created_at")
        if case .timestampCreate = info?.kind {
            // Success
        } else {
            Issue.record("Expected .timestampCreate property kind")
        }
    }

    @Test("analyze detects updatedAt timestamp")
    func updatedAtTimestamp() throws {
        let source = """
            struct User {
                var updatedAt: Date?
            }
            """

        let parsed = Parser.parse(source: source)
        let structDecl = parsed.statements.first?.item.as(StructDeclSyntax.self)
        let varDecl = structDecl?.memberBlock.members.first?.decl.as(VariableDeclSyntax.self)

        let info = try analyzer.analyze(varDecl, in: structDecl!)

        #expect(info != nil)
        #expect(info?.name == "updatedAt")
        #expect(info?.columnName == "updated_at")
        if case .timestampUpdate = info?.kind {
            // Success
        } else {
            Issue.record("Expected .timestampUpdate property kind")
        }
    }

    @Test("analyze detects enum property")
    func enumProperty() throws {
        let source = """
            struct Event {
                var status: EventStatus
            }
            """

        let parsed = Parser.parse(source: source)
        let structDecl = parsed.statements.first?.item.as(StructDeclSyntax.self)
        let varDecl = structDecl?.memberBlock.members.first?.decl.as(VariableDeclSyntax.self)

        let info = try analyzer.analyze(varDecl, in: structDecl!)

        #expect(info != nil)
        #expect(info?.name == "status")
        #expect(info?.columnName == "status")
        #expect(info?.isOptional == false)
        if case .enum(let type, let underlyingType) = info?.kind {
            #expect(type == "EventStatus")
            #expect(underlyingType == "String")
        } else {
            Issue.record("Expected .enum property kind")
        }
    }

    @Test("analyze skips computed properties")
    func skipsComputedProperty() throws {
        let source = """
            struct User {
                var fullName: String {
                    return "John Doe"
                }
            }
            """

        let parsed = Parser.parse(source: source)
        let structDecl = parsed.statements.first?.item.as(StructDeclSyntax.self)
        let varDecl = structDecl?.memberBlock.members.first?.decl.as(VariableDeclSyntax.self)

        let info = try analyzer.analyze(varDecl, in: structDecl!)

        #expect(info == nil)
    }

    @Test("analyze handles multiple property types in struct")
    func multiplePropertyTypes() throws {
        let source = """
            struct User {
                var id: UUID?
                var name: String
                var email: String?
                var venueID: UUID
                var createdAt: Date?
            }
            """

        let parsed = Parser.parse(source: source)
        let structDecl = parsed.statements.first?.item.as(StructDeclSyntax.self)
        let members = structDecl?.memberBlock.members ?? []

        var properties: [PropertyInfo] = []
        for member in members {
            let varDecl = member.decl.as(VariableDeclSyntax.self)
            if let info = try analyzer.analyze(varDecl, in: structDecl!) {
                properties.append(info)
            }
        }

        #expect(properties.count == 5)

        // Verify ID
        #expect(properties[0].name == "id")
        if case .id = properties[0].kind {
        } else {
            Issue.record("Expected first property to be .id")
        }

        // Verify required field
        #expect(properties[1].name == "name")
        if case .field = properties[1].kind {
        } else {
            Issue.record("Expected second property to be .field")
        }

        // Verify optional field
        #expect(properties[2].name == "email")
        if case .optionalField = properties[2].kind {
        } else {
            Issue.record("Expected third property to be .optionalField")
        }

        // Verify parent
        #expect(properties[3].name == "venueID")
        if case .parent = properties[3].kind {
        } else {
            Issue.record("Expected fourth property to be .parent")
        }

        // Verify timestamp
        #expect(properties[4].name == "createdAt")
        if case .timestampCreate = properties[4].kind {
        } else {
            Issue.record("Expected fifth property to be .timestampCreate")
        }
    }
}
