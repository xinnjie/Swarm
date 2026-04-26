import Foundation
import Testing
import Swarm
import SwarmOpenTelemetry

private struct PromptOnlyProvider: InferenceProvider {
    func generate(prompt: String, options: InferenceOptions) async throws -> String {
        prompt
    }

    func stream(prompt: String, options: InferenceOptions) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(prompt)
            continuation.finish()
        }
    }

    func generateWithToolCalls(
        prompt: String,
        tools: [ToolSchema],
        options: InferenceOptions
    ) async throws -> InferenceResponse {
        InferenceResponse(content: prompt)
    }
}

private struct ToolStreamingProvider: InferenceProvider, ToolCallStreamingInferenceProvider {
    func generate(prompt: String, options: InferenceOptions) async throws -> String {
        prompt
    }

    func stream(prompt: String, options: InferenceOptions) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(prompt)
            continuation.finish()
        }
    }

    func generateWithToolCalls(
        prompt: String,
        tools: [ToolSchema],
        options: InferenceOptions
    ) async throws -> InferenceResponse {
        InferenceResponse(content: prompt)
    }

    func streamWithToolCalls(
        prompt: String,
        tools: [ToolSchema],
        options: InferenceOptions
    ) -> AsyncThrowingStream<InferenceStreamUpdate, Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(.outputChunk(prompt))
            continuation.finish()
        }
    }
}

@Test("OpenTelemetry wrapper does not add unsupported tool streaming")
func openTelemetryWrapperDoesNotAddUnsupportedToolStreaming() {
    let wrapped = PromptOnlyProvider().instrumentedWithOpenTelemetry()

    #expect(!(wrapped is any ToolCallStreamingInferenceProvider))
    #expect(!wrapped.capabilities.contains(.streamingToolCalls))
}

@Test("OpenTelemetry wrapper preserves supported tool streaming")
func openTelemetryWrapperPreservesSupportedToolStreaming() {
    let wrapped = ToolStreamingProvider().instrumentedWithOpenTelemetry()
    let provider: any InferenceProvider = wrapped

    #expect(provider is any ToolCallStreamingInferenceProvider)
    #expect(wrapped.capabilities.contains(.streamingToolCalls))
}

@Test("Inference metadata snapshot exposes non-sensitive provider fields")
func inferenceMetadataSnapshotExposesProviderFields() {
    let endpoint = URL(string: "https://api.example.com/v1")
    let metadata = InferenceProviderMetadataSnapshot(
        providerName: "example",
        modelName: "example-model",
        endpointURL: endpoint
    )

    #expect(metadata.providerName == "example")
    #expect(metadata.modelName == "example-model")
    #expect(metadata.endpointURL == endpoint)
}
