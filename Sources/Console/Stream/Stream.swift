public protocol IOStream: AnyObject {
    func read() -> [UInt8]
    func write(_ bytes: [UInt8])
}
