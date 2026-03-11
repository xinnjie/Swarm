import Testing
@testable import Swarm

@Suite("InlineTool")
struct InlineToolTests {
    @Test func inlineToolExecutesClosure() async throws {
        let tool = InlineTool("reverse", "Reverse a string") { (s: String) in
            String(s.reversed())
        }
        #expect(tool.toolName == "reverse")
        let result = try await tool.execute(input: "hello")
        #expect(result == "olleh")
    }

    @Test func inlineToolBridgesToAnyJSONTool() async throws {
        let tool = InlineTool("upper", "Uppercase") { (s: String) in
            s.uppercased()
        }
        let jsonTool = tool.toAnyJSONTool()
        #expect(jsonTool.name == "upper")
        #expect(jsonTool.description == "Uppercase")
    }

    @Test func inlineToolConformsToToolV3() {
        let tool = InlineTool("test", "Test tool") { (s: String) in s }
        let tools: [any ToolV3] = [tool]
        #expect(tools.count == 1)
    }
}
