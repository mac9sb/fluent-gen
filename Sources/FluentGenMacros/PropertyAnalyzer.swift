import SwiftSyntax

/// The kind of property and how it should be mapped to Fluent
enum PropertyKind {
    case id(type: String)                                   // UUID id
    case field(type: String)                                // Required primitive
    case optionalField(type: String)                        // Optional primitive
    case parent(entityName: String)                         // Foreign key (venueID)
    case timestampCreate                                    // createdAt
    case timestampUpdate                                    // updatedAt
    case `enum`(type: String, underlyingType: String)      // Enum stored as rawValue
}

/// Information about a struct property
struct PropertyInfo {
    let name: String              // camelCase property name
    let columnName: String        // snake_case column name
    let kind: PropertyKind
    let isOptional: Bool
    let originalType: String      // Full type from source
}

/// Analyzes struct properties to determine their Fluent mapping
struct PropertyAnalyzer {
    /// Analyze a property declaration and return PropertyInfo if it's a stored property
    /// Returns nil for computed properties
    func analyze(
        _ decl: VariableDeclSyntax?,
        in context: StructDeclSyntax
    ) throws -> PropertyInfo? {
        guard let decl = decl else { return nil }

        // Skip computed properties (have accessor block)
        if hasAccessorBlock(decl) {
            return nil
        }

        // Extract property name and type
        guard let binding = decl.bindings.first,
              let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
              let typeAnnotation = binding.typeAnnotation else {
            return nil
        }

        let name = pattern.identifier.text
        let type = typeAnnotation.type.description.trimmingCharacters(in: .whitespaces)

        // Determine if optional
        let isOptional = type.contains("?")
        let baseType = type.replacingOccurrences(of: "?", with: "").trimmingCharacters(in: .whitespaces)

        // Determine property kind
        let kind: PropertyKind

        if name == "id" && baseType.contains("UUID") {
            kind = .id(type: "UUID")
        } else if name == "createdAt" {
            kind = .timestampCreate
        } else if name == "updatedAt" {
            kind = .timestampUpdate
        } else if name.hasSuffix("ID") {
            // Foreign key: venueID → venue: VenueModel
            let entityName = String(name.dropLast(2))  // Remove "ID"
            kind = .parent(entityName: entityName)
        } else if isKnownEnum(baseType) {
            // Enum types stored as String rawValue
            kind = .enum(type: baseType, underlyingType: "String")
        } else if isOptional {
            kind = .optionalField(type: baseType)
        } else {
            kind = .field(type: baseType)
        }

        return PropertyInfo(
            name: name,
            columnName: NamingConverter.toSnakeCase(name),
            kind: kind,
            isOptional: isOptional,
            originalType: type
        )
    }

    /// Check if property has accessor block (getter/setter) - computed property
    private func hasAccessorBlock(_ decl: VariableDeclSyntax) -> Bool {
        decl.bindings.contains { binding in
            binding.accessorBlock != nil
        }
    }

    /// Check if a type is a known enum
    /// For MVP, use heuristic based on common enum names
    /// Future: Could analyze sibling declarations or use type metadata
    private func isKnownEnum(_ typeName: String) -> Bool {
        let knownEnums = [
            "EventStatus",
            "UserRole",
            "VenueTier",
            "TicketType"
        ]
        return knownEnums.contains(typeName)
    }
}
