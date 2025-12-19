/// Utilities for converting between naming conventions
enum NamingConverter {
    /// Convert camelCase to snake_case
    /// Examples: phoneNumber → phone_number, venueID → venue_id
    static func toSnakeCase(_ input: String) -> String {
        var result = ""
        let chars = Array(input)

        for (index, char) in chars.enumerated() {
            if char.isUppercase {
                // Don't add underscore at the beginning
                if index > 0 {
                    // Check if previous char was lowercase or if this is the last uppercase in a sequence
                    let prevIsLower = chars[index - 1].isLowercase
                    let nextIsLower = index + 1 < chars.count && chars[index + 1].isLowercase

                    // Add underscore if:
                    // 1. Previous char was lowercase (phoneNumber: e→N)
                    // 2. This is last uppercase before lowercase in sequence (URLString: L→S)
                    if prevIsLower || (index > 1 && nextIsLower && chars[index - 1].isUppercase) {
                        result += "_"
                    }
                }
                result += char.lowercased()
            } else {
                result += String(char)
            }
        }
        return result
    }

    /// Pluralize a word (simple implementation)
    /// Examples: venue → venues, event → events, category → categories
    static func pluralize(_ input: String) -> String {
        let lowercased = input.lowercased()
        if lowercased.hasSuffix("s") {
            return lowercased + "es"  // address → addresses
        } else if lowercased.hasSuffix("y") {
            return String(lowercased.dropLast()) + "ies"  // category → categories
        } else {
            return lowercased + "s"  // venue → venues
        }
    }

    /// Generate model class name from struct name
    /// Example: Venue → VenueModel
    static func modelClassName(_ structName: String) -> String {
        structName + "Model"
    }

    /// Capitalize first letter
    /// Example: venue → Venue
    static func capitalize(_ input: String) -> String {
        guard !input.isEmpty else { return input }
        return input.prefix(1).uppercased() + input.dropFirst()
    }
}
