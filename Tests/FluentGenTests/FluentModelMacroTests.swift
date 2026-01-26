import Testing

@testable import FluentGenMacros

@Suite("FluentModelMacro Tests")
struct FluentModelMacroTests {
    @Test("Macro expansion tests skipped without XCTest")
    func skipMacroExpansionTests() {
        #expect(true)
    }
}
