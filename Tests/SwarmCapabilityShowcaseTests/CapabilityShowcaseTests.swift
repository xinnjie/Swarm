import Testing
@testable import SwarmCapabilityShowcaseSupport

@Suite("Swarm Capability Showcase", .serialized)
struct CapabilityShowcaseTests {
    @Test("registry covers every required capability family")
    func registryCoversRequiredFamilies() {
        let showcase = CapabilityShowcase()
        let coveredFamilies = Set(showcase.scenarios.flatMap(\.families))

        #expect(coveredFamilies == CapabilityShowcase.requiredFamilies)
    }

    @Test("deterministic scenarios pass")
    func deterministicScenariosPass() async throws {
        let showcase = CapabilityShowcase()
        var results = try await showcase.runDeterministicScenarios()

        let failedIDs = results
            .filter { $0.status == .failed }
            .map(\.id)

        if !failedIDs.isEmpty {
            var recovered: [CapabilityScenarioResult] = []
            for id in failedIDs {
                recovered.append(try await showcase.runScenario(id: id))
            }

            var recoveredByID: [String: CapabilityScenarioResult] = [:]
            for result in recovered {
                recoveredByID[result.id] = result
            }

            results = results.map { recoveredByID[$0.id] ?? $0 }
        }

        #expect(results.isEmpty == false)
        if !results.allSatisfy({ $0.status == .passed }) {
            Issue.record("Capability showcase summary:\n\(CapabilityShowcase.renderSummary(results))")
        }
        #expect(results.allSatisfy { $0.status == .passed })
    }

    @Test("summary formatter includes ids and statuses")
    func summaryFormatterIncludesIdsAndStatuses() {
        let summary = CapabilityShowcase.renderSummary([
            CapabilityScenarioResult(
                id: "agent-tools",
                name: "Agent Tools",
                families: [.agentTools],
                status: .passed,
                summary: "ok"
            ),
            CapabilityScenarioResult(
                id: "mcp",
                name: "MCP",
                families: [.mcp],
                status: .skipped,
                summary: "missing env"
            ),
        ])

        #expect(summary.contains("agent-tools"))
        #expect(summary.contains("mcp"))
        #expect(summary.contains("passed"))
        #expect(summary.contains("skipped"))
    }
}
