import ConsoleKit
import Synchronization

final class TestConsole: Console {
    let _testInputQueue: Mutex<[String]> = Mutex([])

    var testInputQueue: [String] {
        get { self._testInputQueue.withLock { $0 } }
        set { self._testInputQueue.withLock { $0 = newValue } }
    }

    let _testOutputQueue: Mutex<[String]> = Mutex([])
    var testOutputQueue: [String] {
        get { self._testOutputQueue.withLock { $0 } }
        set { self._testOutputQueue.withLock { $0 = newValue } }
    }

    let _userInfo: Mutex<[AnySendableHashable: any Sendable]> = Mutex([:])
    var userInfo: [AnySendableHashable: any Sendable] {
        get { self._userInfo.withLock { $0 } }
        set { self._userInfo.withLock { $0 = newValue } }
    }

    init() {
        self.testInputQueue = []
        self.testOutputQueue = []
        self.userInfo = [:]
    }

    func input(isSecure: Bool) -> String {
        return testInputQueue.popLast() ?? ""
    }

    func output(_ text: ConsoleText, newLine: Bool) {
        testOutputQueue.insert(text.description + (newLine ? "\n" : ""), at: 0)
    }

    func report(error: String, newLine: Bool) {}

    func clear(_ type: ConsoleClear) {}

    var size: (width: Int, height: Int) { (width: 32, height: 0) }
}
