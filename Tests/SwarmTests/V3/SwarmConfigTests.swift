import Testing
@testable import Swarm

@Suite("SwarmConfig", .serialized)
struct SwarmConfigTests {
    @Test func configureStoresGlobalProvider() async {
        let mock = MockInferenceProvider(responses: [])
        await Swarm.configure(provider: mock)
        let provider = await Swarm.defaultProvider
        #expect(provider != nil)
        // Clean up
        await Swarm.reset()
    }

    @Test func configureCloudProvider() async {
        let mock = MockInferenceProvider(responses: [])
        await Swarm.configure(cloudProvider: mock)
        let provider = await Swarm.cloudProvider
        #expect(provider != nil)
        // Clean up
        await Swarm.reset()
    }

    @Test func resetClearsProviders() async {
        let mock = MockInferenceProvider(responses: [])
        await Swarm.configure(provider: mock)
        await Swarm.reset()
        let provider = await Swarm.defaultProvider
        #expect(provider == nil)
    }
}
