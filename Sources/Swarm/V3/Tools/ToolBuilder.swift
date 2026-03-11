/// Result builder for composing `[any ToolV3]` in trailing closures.
///
/// ```swift
/// let agent = AgentV3("Help.") {
///     GreetTool()
///     SearchTool()
/// }
/// ```
@resultBuilder
public struct ToolBuilder {
    public static func buildBlock(_ components: [any ToolV3]...) -> [any ToolV3] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: any ToolV3) -> [any ToolV3] {
        [expression]
    }

    public static func buildArray(_ components: [[any ToolV3]]) -> [any ToolV3] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [any ToolV3]?) -> [any ToolV3] {
        component ?? []
    }

    public static func buildEither(first component: [any ToolV3]) -> [any ToolV3] {
        component
    }

    public static func buildEither(second component: [any ToolV3]) -> [any ToolV3] {
        component
    }
}
