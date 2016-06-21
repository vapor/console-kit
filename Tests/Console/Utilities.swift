import XCTest
import Console

class TestConsole: Console {

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
}
