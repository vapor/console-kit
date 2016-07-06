import Foundation

extension FileHandle: Stream {
    public func read() -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: availableData.count)
        availableData.copyBytes(to: &bytes, count: availableData.count)
        return bytes
    }

    public func write(_ bytes: [UInt8]) {
        write(Data(bytes: bytes))
    }
}
