import libc
import Foundation

public class Terminal: ConsoleProtocol {
    public enum Error: Swift.Error {
        case cancelled
        case execute(Int)
    }

    public let arguments: [String]
    
    /**
        Creates an instance of Terminal.
    */
    public init(arguments: [String]) {
        pids = []
        self.arguments = arguments
    }

    /**
        Prints styled output to the terminal.
    */
    public func output(_ string: String, style: ConsoleStyle, newLine: Bool) {
        let terminator = newLine ? "\n" : ""

        let output: String
        if let color = style.terminalColor {
            #if !Xcode
                output = string.terminalColorize(color)
            #else
                output = string
            #endif
        } else {
            output = string
        }

        Swift.print(output, terminator: terminator)
    }

    /**
        Clears text from the terminal window.
    */
    public func clear(_ clear: ConsoleClear) {
        #if !Xcode
        switch clear {
        case .line:
            command(.cursorUp)
            command(.eraseLine)
        case .screen:
            command(.eraseScreen)
        }
        #endif
    }

    /**
        Reads a line of input from the terminal.
    */
    public func input() -> String {
        return readLine(strippingNewline: true) ?? ""
    }

    public var pids: [pid_t]

    public func execute(_ command: String, input: Int32? = nil, output: Int32? = nil, error: Int32? = nil) throws {
        let task = Task()
        var pid = pid_t()

        let args = ["/bin/sh", "-c", command]
        let argv: [UnsafeMutablePointer<CChar>?] = args.map{ $0.withCString(strdup) }
        defer { for case let arg? in argv { free(arg) } }

        var environment: [String: String] = [:]
        #if Xcode
            let keys = ["SWIFT_EXEC", "HOME", "PATH", "TOOLCHAINS", "DEVELOPER_DIR", "LLVM_PROFILE_FILE"]
        #else
            let keys = ["SWIFT_EXEC", "HOME", "PATH", "SDKROOT", "TOOLCHAINS", "DEVELOPER_DIR", "LLVM_PROFILE_FILE"]
        #endif

        func getenv(_ key: String) -> String? {
            let out = libc.getenv(key)
            return out == nil ? nil : String(validatingUTF8: out!)  //FIXME locale may not be UTF8
        }

        for key in keys {
            if environment[key] == nil {
                environment[key] = getenv(key)
            }
        }

        let env: [UnsafeMutablePointer<CChar>?] = environment.map{ "\($0.0)=\($0.1)".withCString(strdup) }
        defer { for case let arg? in env { free(arg) } }


        #if os(macOS)
            var fileActions: posix_spawn_file_actions_t? = nil
        #else
            var fileActions = posix_spawn_file_actions_t()
        #endif

        posix_spawn_file_actions_init(&fileActions);
        defer {
            posix_spawn_file_actions_destroy(&fileActions)
        }

        if let input = input {
            posix_spawn_file_actions_adddup2(&fileActions, input, 0)
        }

        if let output = output {
            posix_spawn_file_actions_adddup2(&fileActions, output, 1)
        }

        if let error = error {
            posix_spawn_file_actions_adddup2(&fileActions, error, 2)
        }

        let result = posix_spawnp(&pid, argv[0], &fileActions, nil, argv + [nil], env + [nil])
        pids.append(pid)

        if result == 2 {
            throw ConsoleError.cancelled
        } else if result != 0 {
            throw ConsoleError.execute(Int(result))
        }
    }

    public var confirmOverride: Bool? {
        if arguments.contains("-y") {
            return true
        } else if arguments.contains("-n") {
            return false
        }

        return nil
    }

    public var size: (width: Int, height: Int) {
        // Get the columns and lines from tput
        let tput = "/usr/bin/tput"

        do {
            // FIXME: tput doesn't work with NSTask
            let cols = try backgroundExecute("\(tput) cols").trim()
            let lines = try backgroundExecute("\(tput) lines").trim()

            return (Int(cols) ?? 0, Int(lines) ?? 0)
        } catch {
            return (0, 0)
        }
    }

    /**
        Runs an ansi coded command.
    */
    private func command(_ command: Command) {
        output(command.ansi, newLine: false)
    }
}
