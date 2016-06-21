public class Bar {
    let console: Console
    let title: String
    let width: Int
    let barStyle: ConsoleStyle
    let statusStyle: ConsoleStyle
    var hasStarted: Bool

    public init(console: Console, title: String, width: Int, barStyle: ConsoleStyle, statusStyle: ConsoleStyle) {
        self.console = console
        self.width = width
        self.title = title
        self.barStyle = barStyle
        self.statusStyle = statusStyle
        hasStarted = false
    }

    public func fail(_ message: String? = nil) {
        let message = message ?? "Failed"

        prepareLine()
        console.output(title, style: statusStyle, newLine: false)
        console.output(" [\(message)]", style: .error)
    }

    public func finish(_ message: String? = nil) {
        let message = message ?? "Done"

        prepareLine()
        console.output(title, style: statusStyle, newLine: false)
        console.output(" [\(message)]", style: .success)
    }

    public func update() {
        prepareLine()
        
        console.output(title + " ", style: statusStyle, newLine: false)
        console.output(bar, style: barStyle, newLine: false)
        console.output(status, style: statusStyle)
    }

    public func prepareLine() {
        if hasStarted {
            console.clear(.line)
        } else {
            hasStarted = true
        }
    }

    var bar: String {
        return ""
    }

    var status: String {
        return ""
    }
}
