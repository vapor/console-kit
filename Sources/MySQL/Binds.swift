#if os(Linux)
    import CMySQLLinux
#else
    import CMySQLMac
#endif

public final class Binds {
    public typealias CBinds = UnsafeMutablePointer<Bind.CBind>

    public let cBinds: CBinds
    public let binds: [Bind]


    public convenience init(_ values: [Value]) {
        let binds = values.map { $0.bind }
        self.init(binds)
    }

    public init(_ binds: [Bind]) {
        let cBinds = CBinds(allocatingCapacity: binds.count)

        for (i, bind) in binds.enumerated() {
            cBinds[i] = bind.cBind
        }

        self.cBinds = cBinds
        self.binds = binds
    }

    public convenience init(_ fields: Fields) {
        var binds: [Bind] = []

        for field in fields.fields {
            let bind = Bind(field)
            binds.append(bind)
        }

        self.init(binds)
    }

    deinit {
        cBinds.deallocateCapacity(binds.count)
    }

    public subscript(int: Int) -> Bind {
        return binds[int]
    }
}
