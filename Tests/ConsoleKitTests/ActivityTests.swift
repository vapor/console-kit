import ConsoleKit
import Testing

@Suite("Activity Tests")
struct ActivityTests {
    @Test("Loading")
    func loading() async throws {
        let console = Terminal()
        let foo = console.loadingBar(title: "Loading")

        try await foo.withActivityIndicator {
            try await Task.sleep(for: .seconds(2.5))
        }

        enum TestError: Error {
            case test
        }
        await #expect(throws: TestError.test) {
            try await foo.withActivityIndicator {
                throw TestError.test
            }
        }
    }

    @Test("Progress")
    func progress() async throws {
        let console = Terminal()
        let foo = console.progressBar(title: "Progress")

        try await foo.withActivityIndicator {
            while true {
                if foo.activity.currentProgress >= 1.0 {
                    return
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

        let indicator = console.customActivity(title: "Loading", frames: ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"])

        try await indicator.withActivityIndicator {
            try await Task.sleep(for: .seconds(3))
        }
    }

    @Test("Custom Indicator with ConsoleText")
    func customIndicatorWithConsoleText() async throws {
        let console = Terminal()

        let frames: [ConsoleText] = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
        let indicator = console.customActivity(title: "Loading", frames: frames)

        try await indicator.withActivityIndicator {
            try await Task.sleep(for: .seconds(3))
        }
    }

    @Test("Activity Width Key")
    func activityWidthKey() {
        var dict = [AnySendableHashable: String]()
        dict[AnySendableHashable("ConsoleKit.Tests")] = "string key"

        #expect(dict[AnySendableHashable("ConsoleKit.Tests")] == "string key")
        #expect(dict.keys.contains { $0.description == "ConsoleKit.Tests" })
        #expect(dict.keys.contains { $0.debugDescription == "AnyHashable(\"ConsoleKit.Tests\")" })
        #expect(dict.keys.first?.customMirror.displayStyle == nil)

        let console = Terminal()
        #expect(console.activityBarWidth == 25)
        console.activityBarWidth = 30
        #expect(console.activityBarWidth == 30)
    }
}
