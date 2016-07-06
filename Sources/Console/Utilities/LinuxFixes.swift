import Foundation

#if os(Linux)
typealias Pipe = NSPipe
typealias FileHandle = NSFileHandle
typealias Task = NSTask
#endif
