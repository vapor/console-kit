import XCTest
import Console

class TestConsole: ConsoleProtocol {

    var inputBuffer: String = ""
    var outputBuffer: String = ""

    var size: (width: Int, height: Int) {
        return (80, 25)
    }
    
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

    func secureInput() -> String {
        return input()
    }


    func clear(_ clear: ConsoleClear) {
        //
    }

    func execute(program: String, arguments: [String], input: Int32?, output: Int32?, error: Int32?) throws {

    }

    func registerKillListener(_ listener: @escaping (Int32) -> Void) {

    }
}
