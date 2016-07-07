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
}
#endif
