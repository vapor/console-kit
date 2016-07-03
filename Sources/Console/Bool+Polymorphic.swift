import Polymorphic

extension Bool: Polymorphic {
    public var isNull: Bool {
        return false
    }

    public var bool: Bool? {
        return self
    }

    public var float: Float? {
        return self ? 1.0 : 0.0
    }

    public var double: Double? {
        return self ? 1.0 : 0.0
    }

    public var int: Int? {
        return self ? 1 : 0
    }

    public var string: String? {
        return self ? "true" : "false"
    }

    public var array: [Polymorphic]? {
        return nil
    }

    public var object: [String: Polymorphic]? {
        return nil
    }
}
