public protocol Stream: AnyObject {
    func read() -> [UInt8]
    func write(_ bytes: [UInt8])
}
