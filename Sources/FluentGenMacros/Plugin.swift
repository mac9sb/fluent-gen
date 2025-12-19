import SwiftCompilerPlugin
import SwiftSyntaxMacros

/// Compiler plugin entry point
@main
struct FluentGenPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FluentModelMacro.self
    ]
}
