import XCTest
import Console

class TestConsole: ConsoleProtocol {

    var inputBuffer: String = ""
    var outputBuffer: String = ""

    func output(_ string: String, style: ConsoleStyle, newLine: Bool) {
        outputBuffer += string
        if newLine {
            outputBuffer += "\n"
        }
    }

    func input() -> String {
        let input = inputBuffer
        inputBuffer = ""
        return input
    }

    func clear(_ clear: ConsoleClear) {
        //
    }

    func execute(_ command: String) throws {

    }

    func subexecute(_ command: String, input: String) throws -> String {
        return ""
    }

    var size: (width: Int, height: Int) {
        return (0, 0)
    }
}
