import XCTest
@testable import FluentGenMacros

final class NamingConverterTests: XCTestCase {
    func testToSnakeCase() {
        XCTAssertEqual(NamingConverter.toSnakeCase("phoneNumber"), "phone_number")
        XCTAssertEqual(NamingConverter.toSnakeCase("venueID"), "venue_id")
        XCTAssertEqual(NamingConverter.toSnakeCase("name"), "name")
        XCTAssertEqual(NamingConverter.toSnakeCase("isActive"), "is_active")
        XCTAssertEqual(NamingConverter.toSnakeCase("createdAt"), "created_at")
        XCTAssertEqual(NamingConverter.toSnakeCase("updatedAt"), "updated_at")
        XCTAssertEqual(NamingConverter.toSnakeCase("firstName"), "first_name")
        XCTAssertEqual(NamingConverter.toSnakeCase("lastName"), "last_name")
    }

    func testPluralize() {
        XCTAssertEqual(NamingConverter.pluralize("Venue"), "venues")
        XCTAssertEqual(NamingConverter.pluralize("Event"), "events")
        XCTAssertEqual(NamingConverter.pluralize("User"), "users")
        XCTAssertEqual(NamingConverter.pluralize("Guest"), "guests")
        XCTAssertEqual(NamingConverter.pluralize("Ticket"), "tickets")
        XCTAssertEqual(NamingConverter.pluralize("Message"), "messages")
        XCTAssertEqual(NamingConverter.pluralize("Category"), "categories")
        XCTAssertEqual(NamingConverter.pluralize("Address"), "addresses")
    }

    func testModelClassName() {
        XCTAssertEqual(NamingConverter.modelClassName("Venue"), "VenueModel")
        XCTAssertEqual(NamingConverter.modelClassName("Event"), "EventModel")
        XCTAssertEqual(NamingConverter.modelClassName("User"), "UserModel")
    }

    func testCapitalize() {
        XCTAssertEqual(NamingConverter.capitalize("venue"), "Venue")
        XCTAssertEqual(NamingConverter.capitalize("event"), "Event")
        XCTAssertEqual(NamingConverter.capitalize(""), "")
        XCTAssertEqual(NamingConverter.capitalize("a"), "A")
    }
}
