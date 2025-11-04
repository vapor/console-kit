#if canImport(Darwin)
import Darwin.C
#elseif canImport(Glibc)
@preconcurrency import Glibc
#elseif canImport(Musl)
@preconcurrency import Musl
#elseif canImport(Android)
@preconcurrency import Android
#elseif os(WASI)
import WASILibc
#elseif os(Windows)
import CRT
#endif

enum ANSIColor: String {
    case red = "\u{001B}[31m"
    case green = "\u{001B}[32m"
    case yellow = "\u{001B}[33m"
    case cyan = "\u{001B}[36m"
    case brightRed = "\u{001B}[91m"
}

extension String{
    func colored(_ color: ANSIColor?) -> String {
        guard supportsANSICommands, let color else { return self }
        return color.rawValue + self + "\u{001B}[0m"
    }
}

private var supportsANSICommands: Bool {
    #if Xcode
    // Xcode output does not support ANSI commands
    return false
    #else
    // If STDOUT is not an interactive terminal then omit ANSI commands
    return isatty(STDOUT_FILENO) > 0
    #endif
}
