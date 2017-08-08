import Consoles

final class TestConsole: Console {
    var output: String
    var input: String
    var error: String
    var lastAction: Action?
    var extend: [String : Any] = [:]

    init() {
        self.output = ""
        self.input = ""
        self.error = ""
        self.lastAction = nil
    }

    func action(_ action: Action) throws -> String? {
        switch action {
        case .input(_):
            let t = input
            input = ""
            return t
        case .output(let output, _, let newLine):
            self.output += output + (newLine ? "\n" : "")
        case .error(let error, let newLine):
            self.error += error + (newLine ? "\n" : "")
        default:
            break
        }
        lastAction = action
        return nil
    }

    var size: (width: Int, height: Int) {
        return (640, 320)
    }
}
