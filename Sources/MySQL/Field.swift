#if os(Linux)
    import CMySQLLinux
#else
    import CMySQLMac
#endif

/**
    Wraps a MySQL C field struct.
*/
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
