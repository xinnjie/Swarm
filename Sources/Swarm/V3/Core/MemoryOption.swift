/// Factory enum for memory selection. Dot-syntax construction replaces manual memory init.
///
/// ```swift
/// let agent = AgentV3("Help.")
///     .memory(.conversation(limit: 50))
/// ```
public enum MemoryOption: Sendable {
    case none
    case conversation(limit: Int = 100)
    case slidingWindow(maxTokens: Int = 4000)
    case custom(any Memory)

    /// Constructs the memory instance. Returns `nil` for `.none`.
    public func makeMemory() -> (any Memory)? {
        switch self {
        case .none:
            return nil
        case .conversation(let limit):
            return ConversationMemory(maxMessages: limit)
        case .slidingWindow(let maxTokens):
            return SlidingWindowMemory(maxTokens: maxTokens)
        case .custom(let memory):
            return memory
        }
    }
}
