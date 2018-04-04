extension Console {
    ///
    ///     let loadingBar = console.loadingBar(title: "Loading")
    ///     background {
    ///         // complete the loading bar after 3 seconds
    ///         console.blockingWait(seconds: 3)
    ///         loadingBar.succeed()
    ///     }
    ///     // start the loading bar and wait for it to finish
    ///     try loadingBar.start(on: ...).wait()
    ///
    public func loadingBar(title: String) -> ActivityIndicator<LoadingBar> {
        return LoadingBar(title: title).newActivity(for: self)
    }
}

public struct LoadingBar: ActivityBar {
    public static var width: Int = 25
    public var title: String

    public func renderActiveBar(tick: UInt) -> String {
        let period = LoadingBar.width - 1
        let offset = Int(tick) % period
        let reverse = Int(tick) % (period * 2) >= period

        let increasing = offset
        let decreasing = LoadingBar.width - offset - 1

        let left: Int
        let right: Int
        if reverse {
            left = decreasing
            right = increasing
        } else {
            left = increasing
            right = decreasing
        }

        var barComponents: [String] = []
        barComponents.append("[")
        barComponents.append(.init(repeating: " ", count: left))
        barComponents.append("•")
        barComponents.append(.init(repeating: " ", count: right))
        barComponents.append("]")
        return barComponents.joined(separator: "")
    }
}
