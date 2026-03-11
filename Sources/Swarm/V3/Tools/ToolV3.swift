// MARK: - @ParameterV3

/// Property wrapper for declaring tool parameters with descriptions.
///
/// ```swift
/// struct GreetTool: ToolV3 {
///     @ParameterV3("Name of the person") var name: String = ""
///     func call() async throws -> String { "Hello, \(name)!" }
/// }
/// ```
@propertyWrapper
public struct ParameterV3<Value: Sendable>: Sendable {
    public var wrappedValue: Value
    public let description: String

    public init(wrappedValue: Value, _ description: String) {
        self.wrappedValue = wrappedValue
        self.description = description
    }
}

extension ParameterV3 where Value: ExpressibleByNilLiteral {
    public init(_ description: String) {
        self.wrappedValue = nil
        self.description = description
    }
}

// MARK: - ToolV3

/// User-facing tool protocol for V3 API. No associated types — safe as existential `[any ToolV3]`.
///
/// Implement `toAnyJSONTool()` to bridge into the existing `AgentRuntime` wire protocol.
/// The `@Tool` macro generates this bridge automatically.
public protocol ToolV3: Sendable {
    static var name: String { get }
    static var description: String { get }
    func call() async throws -> String
    func toAnyJSONTool() -> any AnyJSONTool
}
