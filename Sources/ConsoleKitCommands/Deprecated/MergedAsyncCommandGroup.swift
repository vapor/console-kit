@available(*, deprecated, message: "This API should not have been made public and is obsolete; do not use it.")
public struct MergedAsyncCommandGroup: AsyncCommandGroup {
    public let commands: [String: any AnyAsyncCommand]
    public let defaultCommand: (any AnyAsyncCommand)?
    public var help: String
}

extension AsyncCommandGroup {
    @available(*, deprecated, message: "This API should not have been made public and is obsolete; do not use it.")
    public func merge(
        with group: any AsyncCommandGroup,
        defaultCommand: (any AnyAsyncCommand)?,
        help: String
    ) -> any AsyncCommandGroup {
        MergedAsyncCommandGroup(commands: self.commands.merging(group.commands, uniquingKeysWith: { $1 }), defaultCommand: defaultCommand, help: help)
    }
}
