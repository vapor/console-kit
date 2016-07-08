import Foundation

extension FileHandle: IOStream {
    public func read() -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: availableData.count)
        availableData.copyBytes(to: &bytes, count: availableData.count)
        return bytes
    }

    public func write(_ bytes: [UInt8]) {
        #if os(Linux)
            write(bytes)
        #else
            write(Data(bytes: bytes))
        #endif
    }
}
