/**
    A loading bar that indicates ongoing activity.

    progress = 0.5 // updated progress
        Loading Item [===    ] 50%

    fail()
        Loading Item [Failed]

    finish()
        Loading Item [Done]
*/
public class ProgressBar: Bar {
    public var progress: Double {
        didSet {
            update()
        }
    }

    override init(console: Console, title: String, width: Int, barStyle: ConsoleStyle, titleStyle: ConsoleStyle) {
        progress = 0
        super.init(console: console, title: title, width: width, barStyle: barStyle, titleStyle: titleStyle)
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
