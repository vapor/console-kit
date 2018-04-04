public protocol ActivityIndicatorType {
    func outputActivityIndicator(to console: Console, state: ActivityIndicatorState)
}

public enum ActivityIndicatorState {
    case ready
    case active(tick: UInt)
    case done
    case fail
}
