import Foundation

#if os(Linux)
typealias Pipe = NSPipe
typealias FileHandle = NSFileHandle
typealias Task = NSTask
typealias Data = NSData

extension Data {
    public var count: Int {
        return self.length
    }

    public func copyBytes(to: UnsafeMutablePointer<Void>, count: availableData.count) {
        getBytes(bytes, length: count)
    }

    public convenience init(bytes: [UInt8]) {
        super.init(&bytes, length: bytes.count)
    }
}

extension FileHandle {
    public func standardError() -> FileHandle {
        return fileHandleWithStandardError()
    }

    public func standardOutput() -> FileHandle {
        return fileHandleWithStandardOutput()
    }

    public func standardInput() -> FileHandle {
        return fileHandleWithStandardInput()
    }
}
#endif
