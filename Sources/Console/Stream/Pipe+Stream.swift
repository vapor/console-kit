import Foundation

extension Pipe: Stream {
    public func read() -> [UInt8] {
        return fileHandleForReading.read()
    }

    public func write(_ bytes: [UInt8]) {
        fileHandleForWriting.write(bytes)
    }
}
