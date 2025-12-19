import SwiftSyntax
import SwiftSyntaxMacros

/// Main macro implementation for @FluentModel
public struct FluentModelMacro: PeerMacro {
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
