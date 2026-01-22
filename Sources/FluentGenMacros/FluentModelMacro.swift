import SwiftSyntax
import SwiftSyntaxMacros

/// Macro implementation that generates Fluent model classes from struct declarations.
///
/// This macro analyzes a struct declaration and generates a corresponding Fluent
/// model class with appropriate property wrappers, initializers, and conversion methods.
///
/// The generated model follows Fluent ORM conventions and includes:
/// - Table schema definition
/// - Property wrappers (@ID, @Field, @OptionalField, @Parent, @Timestamp)
/// - Initializers for creating from DTOs
/// - Conversion methods to DTOs
public struct FluentModelMacro: PeerMacro {
    /// Expands the macro to generate a Fluent model class.
    ///
    /// Analyzes the struct declaration, extracts property information, and generates
    /// a peer Fluent model class.
    ///
    /// - Parameters:
    ///   - node: The attribute syntax node.
    ///   - declaration: The struct declaration being expanded.
    ///   - context: The macro expansion context.
    /// - Returns: An array containing the generated model class declaration.
    /// - Throws: `MacroError` if the declaration is not a struct or has invalid properties.
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // 1. Ensure this is a struct declaration
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw MacroError.notAStruct
        }

        // 2. Extract struct name
        let structName = structDecl.name.text

        // 3. Analyze properties
        let analyzer = PropertyAnalyzer()
        let properties = try structDecl.memberBlock.members.compactMap { member -> PropertyInfo? in
            let varDecl = member.decl.as(VariableDeclSyntax.self)
            return try analyzer.analyze(varDecl, in: structDecl)
        }

        // 4. Generate Fluent model class
        let generator = CodeGenerator()
        let modelClass = try generator.generateFluentModel(
            structName: structName,
            properties: properties
        )

        // 5. Return as peer declaration
        return [modelClass]
    }
}

/// Macro errors
enum MacroError: Error, CustomStringConvertible {
    case notAStruct
    case invalidProperty(String)

    var description: String {
        switch self {
        case .notAStruct:
            return "@FluentModel can only be applied to structs"
        case .invalidProperty(let name):
            return "Invalid property '\(name)'"
        }
    }
}
