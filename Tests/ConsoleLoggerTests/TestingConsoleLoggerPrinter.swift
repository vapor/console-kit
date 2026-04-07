import ConsoleLogger
import Synchronization

final class TestingConsoleLoggerPrinter: ConsoleLoggerPrinter {
    let _testOutputQueue: Mutex<[String]> = .init([])
    var testOutputQueue: [String] {
        get { _testOutputQueue.withLock { $0 } }
        set { _testOutputQueue.withLock { $0 = newValue } }
    }

    func print(_ string: String) {
        testOutputQueue.insert(string, at: 0)
    }
}
