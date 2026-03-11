/// Replaces 35-property `AgentConfiguration` with a focused 6-field struct.
/// Use presets for common patterns.
///
/// ```swift
/// let agent = AgentV3("Help.")
///     .options(.precise)
/// ```
public struct RunOptions: Sendable, Equatable {
    public var temperature: Double
    public var maxIterations: Int
    public var maxTokens: Int?
    public var timeout: Duration?
    public var retryLimit: Int
    public var streamingEnabled: Bool

    public init(
        temperature: Double = 0.7,
        maxIterations: Int = 10,
        maxTokens: Int? = nil,
        timeout: Duration? = nil,
        retryLimit: Int = 3,
        streamingEnabled: Bool = false
    ) {
        self.temperature = temperature
        self.maxIterations = maxIterations
        self.maxTokens = maxTokens
        self.timeout = timeout
        self.retryLimit = retryLimit
        self.streamingEnabled = streamingEnabled
    }
}

extension RunOptions {
    public static let `default` = RunOptions()
    public static let creative = RunOptions(temperature: 1.2)
    public static let precise = RunOptions(temperature: 0.0, maxIterations: 5)
    public static let fast = RunOptions(temperature: 0.7, maxIterations: 3, maxTokens: 512)
}
