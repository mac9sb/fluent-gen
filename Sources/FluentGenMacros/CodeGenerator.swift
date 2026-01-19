import SwiftSyntax
import SwiftSyntaxBuilder

/// Generates Fluent model class code from property information
struct CodeGenerator {
    /// Generate a complete Fluent model class
    func generateFluentModel(
        structName: String,
        properties: [PropertyInfo]
    ) throws -> DeclSyntax {
        let modelName = NamingConverter.modelClassName(structName)
        let tableName = NamingConverter.pluralize(structName)

        // Generate class code as a string (simpler than building with SwiftSyntax builders)
        var classCode = """
            public final class \(modelName): Model, @unchecked Sendable {
                public static let schema = "\(tableName)"


            """

        // 1. Generate property declarations
        for prop in properties {
            classCode += generatePropertyDeclaration(prop)
        }

        // 2. Generate empty initializer
        classCode += "\n    public init() {}\n\n"

        // 3. Generate init(from:) converter
        classCode += generateFromDTOInitializer(structName: structName, properties: properties)
        classCode += "\n"

        // 4. Generate toDTO() converter
        classCode += generateToDTOMethod(structName: structName, properties: properties)

        classCode += "}"

        // Convert string to DeclSyntax
        return DeclSyntax(stringLiteral: classCode)
    }

    /// Generate Fluent property declaration with appropriate wrapper
    private func generatePropertyDeclaration(_ prop: PropertyInfo) -> String {
        switch prop.kind {
        case .id:
            return """
                    @ID(key: .id)
                    public var id: UUID?


                """

        case .field(let type):
            return """
                    @Field(key: "\(prop.columnName)")
                    public var \(prop.name): \(type)


                """

        case .optionalField(let type):
            return """
                    @OptionalField(key: "\(prop.columnName)")
                    public var \(prop.name): \(type)?


                """

        case .parent(let entityName):
            let modelType = NamingConverter.modelClassName(
                NamingConverter.capitalize(entityName)
            )
            return """
                    @Parent(key: "\(prop.columnName)")
                    public var \(entityName): \(modelType)


                """

        case .timestampCreate:
            return """
                    @Timestamp(key: "\(prop.columnName)", on: .create)
                    public var \(prop.name): Date?


                """

        case .timestampUpdate:
            return """
                    @Timestamp(key: "\(prop.columnName)", on: .update)
                    public var \(prop.name): Date?


                """

        case .enum(_, _):
            // Enums stored as String rawValue
            guard prop.isOptional else {
                return """
                        @Field(key: "\(prop.columnName)")
                        public var \(prop.name): String


                    """
            }
            return """
                    @OptionalField(key: "\(prop.columnName)")
                    public var \(prop.name): String?


                """
        }
    }

    /// Generate init(from: DTO) converter
    private func generateFromDTOInitializer(
        structName: String,
        properties: [PropertyInfo]
    ) -> String {
        var code = "    public init(from dto: \(structName)) {\n"

        for prop in properties {
            switch prop.kind {
            case .id:
                code += "        self.id = dto.id\n"

            case .field, .optionalField:
                code += "        self.\(prop.name) = dto.\(prop.name)\n"

            case .parent:
                // Set foreign key ID
                let entityName = String(prop.name.dropLast(2))  // Remove "ID"
                code += "        self.$\(entityName).id = dto.\(prop.name)\n"

            case .timestampCreate, .timestampUpdate:
                code += "        self.\(prop.name) = dto.\(prop.name)\n"

            case .enum:
                if prop.isOptional {
                    code += "        self.\(prop.name) = dto.\(prop.name)?.rawValue\n"
                } else {
                    code += "        self.\(prop.name) = dto.\(prop.name).rawValue\n"
                }
            }
        }

        code += "    }\n"
        return code
    }

    /// Generate toDTO() method
    private func generateToDTOMethod(
        structName: String,
        properties: [PropertyInfo]
    ) -> String {
        var code = "    public func toDTO() -> \(structName) {\n"
        code += "        \(structName)(\n"

        for (index, prop) in properties.enumerated() {
            let isLast = index == properties.count - 1
            let separator = isLast ? "" : ","

            switch prop.kind {
            case .id:
                code += "            id: id ?? UUID()\(separator)\n"

            case .field:
                code += "            \(prop.name): \(prop.name)\(separator)\n"

            case .optionalField:
                code += "            \(prop.name): \(prop.name)\(separator)\n"

            case .parent:
                // Read foreign key ID
                let entityName = String(prop.name.dropLast(2))  // Remove "ID"
                code += "            \(prop.name): $\(entityName).id\(separator)\n"

            case .timestampCreate, .timestampUpdate:
                code += "            \(prop.name): \(prop.name)!\(separator)\n"

            case .enum(let type, _):
                if prop.isOptional {
                    code += "            \(prop.name): \(prop.name).flatMap { \(type)(rawValue: $0) }\(separator)\n"
                } else {
                    code += "            \(prop.name): \(type)(rawValue: \(prop.name))!\(separator)\n"
                }
            }
        }

        code += "        )\n"
        code += "    }\n"
        return code
    }
}
