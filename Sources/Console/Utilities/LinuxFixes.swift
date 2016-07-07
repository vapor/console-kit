import Foundation

#if os(Linux)
typealias Pipe = NSPipe
typealias FileHandle = NSFileHandle
typealias Task = NSTask
typealias Data = NSData

extension Data {
    var count: Int {
        return self.length
    }

    func copyBytes(to: UnsafeMutablePointer<Void>, count: availableData.count) {
        getBytes(bytes, length: count)
    }

    convenience init(bytes: [UInt8]) {
        self.init(&bytes, length: bytes.count)
    }
}

extension FileHandle {
    static func standardError() -> FileHandle {
        return fileHandleWithStandardError()
    }

    static func standardOutput() -> FileHandle {
        return fileHandleWithStandardOutput()
    }

    static func standardInput() -> FileHandle {
        return fileHandleWithStandardInput()
    }
}
#endif
