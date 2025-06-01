import Testing

@testable import ConsoleKit

@Suite("Activity Tests")
struct ActivityTests {
    @Test("Loading")
    func loading() async throws {
        let console = Terminal()
        let foo = console.loadingBar(title: "Loading")

        try await foo.withActivityIndicator {
            try await Task.sleep(for: .seconds(2.5))
            return false
        }
    }

    @Test("Progress")
    func progress() async throws {
        let console = Terminal()
        let foo = console.progressBar(title: "Progress")

        try await foo.withActivityIndicator {
            while true {
                if foo.activity.currentProgress >= 1.0 {
                    return true
                } else {
                    foo.activity.currentProgress += 0.1
                    try await Task.sleep(for: .seconds(0.1))
                }
            }
        }
    }

    @Test("Custom Indicator")
    func customIndicator() async throws {
        let console = Terminal()

        let indicator = console.customActivity(frames: ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"])

        try await indicator.withActivityIndicator {
            try await Task.sleep(for: .seconds(3))
            return true
        }
    }

    @Test("Custom Indicator with ConsoleText")
    func customIndicatorWithConsoleText() async throws {
        let console = Terminal()

        let frames: [ConsoleText] = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
        let indicator = console.customActivity(frames: frames)

        try await indicator.withActivityIndicator {
            try await Task.sleep(for: .seconds(3))
            return true
        }
    }

    @Test("Activity Width Key")
    func activityWidthKey() {
        var dict = [AnySendableHashable: String]()

        dict[AnySendableHashable(ActivityBarWidthKey())] = "width key"
        dict[AnySendableHashable("ConsoleKit.ActivityBarWidthKey")] = "string key"

        #expect(dict[AnySendableHashable(ActivityBarWidthKey())] == "width key")
        #expect(dict[AnySendableHashable("ConsoleKit.ActivityBarWidthKey")] == "string key")

        let console = Terminal()
        #expect(console.activityBarWidth == 25)
        console.activityBarWidth = 30
        #expect(console.activityBarWidth == 30)
    }
}
