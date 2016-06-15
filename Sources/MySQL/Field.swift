#if os(Linux)
    import CMySQLLinux
#else
    import CMySQLMac
#endif

public final class Field {
    public typealias CField = MYSQL_FIELD

    public let cField: CField

    public var name: String {
        return String(cString: cField.name)
    }

    public init(_ cField: CField) {
        self.cField = cField
    }
}
