import Testing
@testable import Swarm

@Suite("Workflow")
struct WorkflowTests {
    @Test func workflowAccumulatesSteps() {
        let a = AgentV3("Agent A").named("a")
        let b = AgentV3("Agent B").named("b")
        let wf = Workflow().step(a).step(b)
        #expect(wf.stepCount == 2)
    }

    @Test func parallelCountsAsOneStep() {
        let a = AgentV3("A").named("a")
        let b = AgentV3("B").named("b")
        let wf = Workflow().parallel(a, b)
        #expect(wf.stepCount == 1)
    }

    @Test func workflowIsImmutableValueType() {
        let wf = Workflow()
        let wf2 = wf.step(AgentV3("Agent"))
        #expect(wf.stepCount == 0)
        #expect(wf2.stepCount == 1)
    }

    @Test func mapCountsAsStep() {
        let wf = Workflow().map { $0.uppercased() }
        #expect(wf.stepCount == 1)
    }

    @Test func routeCountsAsStep() {
        let wf = Workflow().route { _ in nil }
        #expect(wf.stepCount == 1)
    }

    @Test func repeatUntilCountsAsStep() {
        let agent = AgentV3("Agent")
        let wf = Workflow().repeatUntil(agent, maxIterations: 3) { $0.contains("DONE") }
        #expect(wf.stepCount == 1)
    }

    @Test func workflowRunsEndToEnd() async throws {
        let mock = MockInferenceProvider(responses: ["Result from agent"])
        let agent = AgentV3("Be helpful.").provider(mock)
        let result = try await Workflow().step(agent).run(input: "Hello")
        #expect(!result.output.isEmpty)
    }

    @Test func workflowChainsSteps() async throws {
        let mock1 = MockInferenceProvider(responses: ["Step 1 output"])
        let mock2 = MockInferenceProvider(responses: ["Step 2 output"])
        let a = AgentV3("Agent A").provider(mock1)
        let b = AgentV3("Agent B").provider(mock2)
        let result = try await Workflow().step(a).step(b).run(input: "Start")
        #expect(result.output.contains("Step 2"))
    }

    @Test func workflowMapTransforms() async throws {
        let result = try await Workflow()
            .map { $0.uppercased() }
            .run(input: "hello")
        #expect(result.output == "HELLO")
    }
}
