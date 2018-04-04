extension Console {
    /// Creates a progress bar using the console.
    public func progressBar(title: String) -> ActivityIndicator<ProgressBar> {
        return ProgressBar(title: title, currentProgress: 0).newActivity(for: self)
    }
}


public struct ProgressBar: ActivityBar {
    public static var width: Int = 25
    public var title: String
    public var currentProgress: Double

    public func renderActiveBar(tick: UInt) -> String {
        let current = min(max(currentProgress, 0.0), 1.0)

        let left = Int(current * Double(ProgressBar.width))
        let right = ProgressBar.width - left

        var barComponents: [String] = []
        barComponents.append("[")
        barComponents.append(.init(repeating: "=", count: Int(left)))
        barComponents.append(.init(repeating: " ", count: Int(right)))
        barComponents.append("]")
        return barComponents.joined(separator: "")
    }
}
