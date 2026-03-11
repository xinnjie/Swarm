import Foundation

/// Replaces 14 protocol/builder/closure guardrail types with a single enum.
/// Returns `nil` = pass, non-nil `String` = block reason.
///
/// ```swift
/// let agent = AgentV3("Help.")
///     .guardrails(.maxInput(characters: 1000), .inputNotEmpty)
/// ```
public enum GuardrailSpec: Sendable {
    // Input guardrails
    case maxInput(characters: Int)
    case inputNotEmpty
    case inputCustom(name: String, validate: @Sendable (String) async throws -> String?)

    // Output guardrails
    case maxOutput(characters: Int)
    case outputCustom(name: String, validate: @Sendable (String) async throws -> String?)

    /// Returns `nil` if valid, block reason string if blocked.
    public func validateInput(_ input: String) async throws -> String? {
        switch self {
        case .maxInput(let max):
            return input.count > max ? "Input exceeds \(max) characters (\(input.count))" : nil
        case .inputNotEmpty:
            return input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "Input must not be empty" : nil
        case .inputCustom(_, let validate):
            return try await validate(input)
        default:
            return nil // Output guardrails don't validate input
        }
    }

    /// Returns `nil` if valid, block reason string if blocked.
    public func validateOutput(_ output: String) async throws -> String? {
        switch self {
        case .maxOutput(let max):
            return output.count > max ? "Output exceeds \(max) characters (\(output.count))" : nil
        case .outputCustom(_, let validate):
            return try await validate(output)
        default:
            return nil // Input guardrails don't validate output
        }
    }
}
