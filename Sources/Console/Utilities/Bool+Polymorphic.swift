extension Bool {
    public var bytes: [UInt8] {
        return self ? [0x01] : [0x00]
    }

    public var int: Int {
        return self ? 1 : 0
    }

    public var string: String {
        return self ? "true" : "false"
    }
}
