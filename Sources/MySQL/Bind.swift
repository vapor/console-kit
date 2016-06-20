#if os(Linux)
    import CMySQLLinux
#else
    import CMySQLMac
#endif

/**
    This structure is used both for statement input (data values sent to the server) 
    and output (result values returned from the server):
 
    The Swift version consists of a wrapper around MySQL's implementation
    to ensure proper freeing of allocated memory.
*/
public final class Bind {
    public typealias CBind = MYSQL_BIND

    /// MySQL represents Characters using signed integers.
    typealias Char = Int8

    /**
        The raw C binding.
    */
    public let cBind: CBind

    /**
        Creates a binding from a raw C binding.
    */
    public init(cBind: CBind) {
        self.cBind = cBind
    }

    /**
        Creates a NULL input binding.
    */
    public init() {
        var cBind = CBind()
        cBind.buffer_type = MYSQL_TYPE_NULL

        self.cBind = cBind
    }

    /**
        Creates an output binding from an expected Field.
    */
    public init(_ field: Field) {
        var cBind = CBind()

        cBind.buffer_type = field.cField.type
        let length = Int(field.cField.length)

        cBind.buffer_length = UInt(length)

        cBind.buffer = UnsafeMutablePointer<Void>(allocatingCapacity: length)
        cBind.length = UnsafeMutablePointer<UInt>(allocatingCapacity: 1)
        cBind.is_null = UnsafeMutablePointer<my_bool>(allocatingCapacity: 1)
        cBind.error = UnsafeMutablePointer<my_bool>(allocatingCapacity: 1)

        self.cBind = cBind
    }

    /**
        Creates an input binding from a String.
    */
    public convenience init(_ string: String) {
        let bytes = Array(string.utf8)
        let buffer = UnsafeMutablePointer<Char>(allocatingCapacity: bytes.count)
        for (i, byte) in bytes.enumerated() {
            buffer[i] = Char(byte)
        }

        self.init(type: MYSQL_TYPE_STRING, buffer: buffer, bufferLength: bytes.count)
    }

    /**
        Creates an input binding from an Int.
    */
    public convenience init(_ int: Int) {
        let buffer = UnsafeMutablePointer<Int64>(allocatingCapacity: 1)
        buffer.initialize(with: Int64(int))

        self.init(type: MYSQL_TYPE_LONGLONG, buffer: buffer, bufferLength: sizeof(Int64))
    }

    /**
        Creates an input binding from a UInt.
    */
    public convenience init(_ int: UInt) {
        let buffer = UnsafeMutablePointer<UInt64>(allocatingCapacity: 1)
        buffer.initialize(with: UInt64(int))

        self.init(type: MYSQL_TYPE_LONGLONG, buffer: buffer, bufferLength: sizeof(UInt64))
    }

    /**
        Creates an input binding from an Double.
    */
    public convenience init(_ int: Double) {
        let buffer = UnsafeMutablePointer<Double>(allocatingCapacity: 1)
        buffer.initialize(with: Double(int))

        self.init(type: MYSQL_TYPE_LONGLONG, buffer: buffer, bufferLength: sizeof(Double))
    }

    /**
        Creates an input binding from a field variant,
        input buffer, and input buffer length.
    */
    public init<T>(type: Field.Variant, buffer: UnsafeMutablePointer<T>, bufferLength: Int, unsigned: Bool = false) {
        var cBind = CBind()

        cBind.buffer = UnsafeMutablePointer<Void>(buffer)
        cBind.buffer_length = UInt(bufferLength)

        cBind.length = UnsafeMutablePointer<UInt>(allocatingCapacity: 1)
        cBind.length.initialize(with: cBind.buffer_length)


        cBind.buffer_type = type

        if unsigned {
            cBind.is_unsigned = 1
        } else {
            cBind.is_unsigned = 0
        }

        self.cBind = cBind
    }

    /**
        Buffer type variant.
    */
    public var variant: Field.Variant {
        return cBind.buffer_type
    }

    /**
        Frees allocated memory from the underlying
        C binding.
    */
    deinit {
        guard cBind.buffer_type != MYSQL_TYPE_NULL else {
            return
        }

        let bufferLength = Int(cBind.buffer_length)

        cBind.buffer.deinitialize()
        cBind.buffer.deallocateCapacity(bufferLength)

        cBind.length.deinitialize()
        cBind.length.deallocateCapacity(1)

        if let pointer = cBind.is_null {
            pointer.deinitialize()
            pointer.deallocateCapacity(1)
        }

        if let pointer = cBind.error {
            pointer.deinitialize()
            pointer.deallocateCapacity(1)
        }
    }
}

extension Value {
    /**
        Creates in input binding from a MySQL Value.
    */
    var bind: Bind {
        switch self {
        case .int(let int):
            return Bind(int)
        case .double(let double):
            return Bind(double)
        case .string(let string):
            return Bind(string)
        case .uint(let uint):
            return Bind(uint)
        case .null:
            return Bind()
        }
    }
}
