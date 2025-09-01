import Synchronization

package final class TestConsole: Console {
    let _testInputQueue: Mutex<[String]> = Mutex([])

    package var testInputQueue: [String] {
        get { self._testInputQueue.withLock { $0 } }
        set { self._testInputQueue.withLock { $0 = newValue } }
    }

    let _testOutputQueue: Mutex<[String]> = Mutex([])
    package var testOutputQueue: [String] {
        get { self._testOutputQueue.withLock { $0 } }
        set { self._testOutputQueue.withLock { $0 = newValue } }
    }

    let _userInfo: Mutex<[AnySendableHashable: any Sendable]> = Mutex([:])
    package var userInfo: [AnySendableHashable: any Sendable] {
        get { self._userInfo.withLock { $0 } }
        set { self._userInfo.withLock { $0 = newValue } }
    }

    package init() {
        self.testInputQueue = []
        self.testOutputQueue = []
        self.userInfo = [:]
    }

    package func input(isSecure: Bool) -> String {
        return testInputQueue.popLast() ?? ""
    }

    package func output(_ text: ConsoleText, newLine: Bool) {
        testOutputQueue.insert(text.description + (newLine ? "\n" : ""), at: 0)
    }

    package func report(error: String, newLine: Bool) {}

    package func clear(_ type: ConsoleClear) {}

    package var size: (width: Int, height: Int) { (width: 32, height: 0) }
}
