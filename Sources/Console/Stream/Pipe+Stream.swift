import Foundation

extension Pipe: IOStream {
    public func read() -> [UInt8] {
        return fileHandleForReading.read()
    }

    public func write(_ bytes: [UInt8]) {
        fileHandleForWriting.write(bytes)
    }
}
