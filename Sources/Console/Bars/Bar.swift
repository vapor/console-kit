import COperatingSystem

public protocol ActivityIndicator {
    var console: Console { get }
    var title: String { get }
    var barStyle: ConsoleStyle { get }
    var titleStyle: ConsoleStyle { get }
}

public protocol ActivityBar: ActivityIndicator {
    var width: Int { get }
}

final class ActivityIndicatorContext {
    var state: ActivityIndicatorState
    var indicator: ActivityIndicator

    init(indicator: ActivityIndicator) {
        self.state = .ready
        self.indicator = indicator
    }
}

enum ActivityIndicatorState {
    case ready
    case done
    case fail
}

extension ActivityBar {

    public func fail(_ message: String? = nil) {
        guard !hasFinished else {
            return
        }
        hasFinished = true

        let message = message ?? "Failed"

        if animated {
            collapseBar(message: message, style: .error)
        } else {
            console.output(title, style: titleStyle, newLine: false)
            console.output(" [\(message)]", style: .error)
        }
    }

    public func finish(_ message: String? = nil) {
        guard !hasFinished else {
            return
        }
        hasFinished = true

        let message = message ?? "Done"

        if animated {
            collapseBar(message: message, style: .success)
        } else {
            console.output(title, style: titleStyle, newLine: false)
            console.output(" [\(message)]", style: .success)
        }
    }

    func collapseBar(message: String, style: ConsoleStyle) {
        pthread_mutex_lock(mutex)
        for i in 0 ..< (width - message.count) {
            prepareLine()

            console.output(title, style: titleStyle, newLine: false)

            let rate = (width - message.count) / message.count
            let charactersShowing = i / rate


            var newBar: String = " ["
            for j in 0 ..< charactersShowing {
                let index = message.index(message.startIndex, offsetBy: j)
                newBar.append(message[index])
            }
            console.output(newBar, style: style, newLine: false)

            var oldBar = ""
            for _ in 0 ..< (width - i - 1 - charactersShowing) {
                let index = bar.index(bar.endIndex, offsetBy: -2)
                oldBar.append(bar[index])
            }
            oldBar.append("]")

            console.output(oldBar, style: barStyle, newLine: true)

            console.blockingWait(seconds: 0.01)
        }

        prepareLine()
        console.output(title, style: titleStyle, newLine: false)
        console.output(" [\(message)]", style: style)
        pthread_mutex_unlock(mutex)
    }

    func update() {
        pthread_mutex_lock(mutex)
        prepareLine()

        let total = title.count + 1 + width + status.count + 2 + 3
        let trimmedTitle: String
        if console.size.width < total {
            var diff = total - console.size.width
            if diff > title.count {
                diff = title.count
            }
            diff = diff * -1
            #if swift(>=4)
            trimmedTitle = title[..<title.index(title.endIndex, offsetBy: diff)] + "..."
            #else 
            trimmedTitle = title.substring(
                to: title.index(title.endIndex, offsetBy: diff)
            ) + "..."
            #endif
        } else {
            trimmedTitle = title
        }

        console.output(trimmedTitle + " ", style: titleStyle, newLine: false)
        console.output(bar, style: barStyle, newLine: false)
        console.output(status, style: titleStyle)
        pthread_mutex_unlock(mutex)
    }

    func prepareLine() {
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

