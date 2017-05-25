import libc
import Foundation

private var _pids: [UnsafeMutablePointer<pid_t>] = []
private var _killListeners: [(Int32) -> Void] = []

public final class Terminal: ConsoleProtocol {
    public enum Error: Swift.Error {
        case cancelled
        case execute(Int)
    }

    public let arguments: [String]

    /**
        Creates an instance of Terminal.
    */
    public init(arguments: [String]) {
        self.arguments = arguments

        func kill(sig: Int32) {
            _killListeners.forEach { listener in
                listener(sig)
            }

            for pid in _pids {
                _ = libc.kill(pid.pointee, sig)
            }
            exit(sig)
        }

        signal(SIGINT, kill)
        signal(SIGTERM, kill)
        signal(SIGQUIT, kill)
        signal(SIGHUP, kill)
    }

    /// Prints styled output to the terminal.
    public func output(_ string: String, style: ConsoleStyle, newLine: Bool) {
        var lines = 0
        if string.characters.count > size.width && size.width > 0 {
            lines = (string.characters.count / size.width) + 1
        }
        if newLine {
            lines += 1
        }
        didOutputLines(count: lines)
        
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
        fflush(stdout)
    }

    /// Clears text from the terminal window.
    public func clear(_ clear: ConsoleClear) {
        #if !Xcode
        switch clear {
        case .line:
            didOutputLines(count: -1)
            // Swift.print("CLEAR LINE")
            command(.cursorUp)
            command(.eraseLine)
        case .screen:
            command(.eraseScreen)
        }
        #endif
    }

    public func input() -> String {
        didOutputLines(count: 1)
        return readLine(strippingNewline: true) ?? ""
    }

    public func secureInput() -> String {
        didOutputLines(count: 1)
        // http://stackoverflow.com/a/30878869/2611971
        let entry: UnsafeMutablePointer<Int8> = getpass("")
        let pointer: UnsafePointer<CChar> = .init(entry)
        var pass = String(validatingUTF8: pointer) ?? ""
        if pass.hasSuffix("\n") {
            pass = pass.makeBytes().dropLast().makeString()
        }
        return pass
    }

    public func execute(
        program: String,
        arguments: [String],
        input: Int32?,
        output: Int32?,
        error: Int32?
    ) throws {
        var pid = UnsafeMutablePointer<pid_t>.allocate(capacity: 1)
        pid.initialize(to: pid_t())
        defer {
            pid.deinitialize()
            pid.deallocate(capacity: 1)
        }


        let args = [program] + arguments
        let argv: [UnsafeMutablePointer<CChar>?] = args.map{ $0.withCString(strdup) }
        defer { for case let arg? in argv { free(arg) } }

        var environment: [String: String] = ProcessInfo.processInfo.environment

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

        _pids.append(pid)
        let spawned = posix_spawnp(pid, argv[0], &fileActions, nil, argv + [nil], env + [nil])
        if spawned != 0 {
            throw ConsoleError.spawnProcess
        }

        var result: Int32 = 0
        _ = waitpid(pid.pointee, &result, 0)
        result = result / 256

        waitpid(pid.pointee, nil, 0)

        if result == ENOENT {
            throw ConsoleError.fileOrDirectoryNotFound
        } else if result != 0 {
            throw ConsoleError.execute(code: Int(result))
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
        var w = winsize()
        _ = ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &w);
        return (Int(w.ws_col), Int(w.ws_row))
    }

    /**
        Runs an ansi coded command.
    */
    private func command(_ command: Command) {
        output(command.ansi, newLine: false)
    }

    public func registerKillListener(_ listener: @escaping (Int32) -> Void) {
        _killListeners.append(listener)
    }
    
    
    public var extend: [String: Any] = [:]
}
