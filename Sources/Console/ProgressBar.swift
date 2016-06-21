public class ProgressBar: Bar {
    public var progress: Double {
        didSet {
            update()
        }
    }

    override init(console: Console, title: String, width: Int, barStyle: ConsoleStyle, statusStyle: ConsoleStyle) {
        progress = 0
        super.init(console: console, title: title, width: width, barStyle: barStyle, statusStyle: statusStyle)
    }

    override var bar: String {
        let current = Int(progress * Double(width))

        var string: String = "["

        for i in 0 ..< width {
            if i <= current {
                string += "="
            } else {
                string += " "
            }
        }

        string += "]"

        return string
    }

    override var status: String {
        let string: String

        let percent = Int(progress * 100.0)
        if percent < 100 {
            string = " \(percent)%"
        } else {
            string = " ✅"
        }

        return string
    }

}

extension Console {
    public func progressBar(
        title: String = "",
        width: Int = 25,
        barStyle: ConsoleStyle = .plain,
        statusStyle: ConsoleStyle = .info
    ) -> ProgressBar {
        return ProgressBar(console: self, title: title, width: width, barStyle: barStyle, statusStyle: statusStyle)
    }
}
