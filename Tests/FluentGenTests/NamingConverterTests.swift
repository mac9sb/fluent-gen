import Testing

@testable import FluentGenMacros

@Suite("NamingConverter Tests")
struct NamingConverterTests {
    @Test("toSnakeCase converts camelCase to snake_case")
    func toSnakeCase() {
        #expect(NamingConverter.toSnakeCase("phoneNumber") == "phone_number")
        #expect(NamingConverter.toSnakeCase("venueID") == "venue_id")
        #expect(NamingConverter.toSnakeCase("name") == "name")
        #expect(NamingConverter.toSnakeCase("isActive") == "is_active")
        #expect(NamingConverter.toSnakeCase("createdAt") == "created_at")
        #expect(NamingConverter.toSnakeCase("updatedAt") == "updated_at")
        #expect(NamingConverter.toSnakeCase("firstName") == "first_name")
        #expect(NamingConverter.toSnakeCase("lastName") == "last_name")
    }

    @Test("toSnakeCase handles consecutive uppercase letters")
    func toSnakeCaseWithConsecutiveUppercase() {
        #expect(NamingConverter.toSnakeCase("URLString") == "url_string")
        #expect(NamingConverter.toSnakeCase("XMLParser") == "xml_parser")
        #expect(NamingConverter.toSnakeCase("HTTPSConnection") == "https_connection")
    }

    @Test("pluralize converts singular words to plural")
    func pluralize() {
        #expect(NamingConverter.pluralize("Venue") == "venues")
        #expect(NamingConverter.pluralize("Event") == "events")
        #expect(NamingConverter.pluralize("User") == "users")
        #expect(NamingConverter.pluralize("Guest") == "guests")
        #expect(NamingConverter.pluralize("Ticket") == "tickets")
        #expect(NamingConverter.pluralize("Message") == "messages")
        #expect(NamingConverter.pluralize("Category") == "categories")
        #expect(NamingConverter.pluralize("Address") == "addresses")
    }

    @Test("modelClassName appends Model suffix")
    func modelClassName() {
        #expect(NamingConverter.modelClassName("Venue") == "VenueModel")
        #expect(NamingConverter.modelClassName("Event") == "EventModel")
        #expect(NamingConverter.modelClassName("User") == "UserModel")
    }

    @Test("capitalize capitalizes first letter")
    func capitalize() {
        #expect(NamingConverter.capitalize("venue") == "Venue")
        #expect(NamingConverter.capitalize("event") == "Event")
        #expect(NamingConverter.capitalize("") == "")
        #expect(NamingConverter.capitalize("a") == "A")
    }
}
