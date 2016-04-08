#if os(Linux)
    import CMySQLLinux
#else
    import CMySQLMac
#endif

public enum MySQLError: ErrorProtocol {
    case NoConnection, BadSQL, IndexOutOfBounds, UnableToBindResults
}

public class MySQL {
    enum FieldType {
        case Null
        case Tiny
        case Short
        case Long
        case LongLong
        case Float
        case Double
        case String
        case Date
        case Data
    }
    
    public typealias BindHandler = (() throws -> ())
    private var mysql: UnsafeMutablePointer<MYSQL>!
    private var statement: UnsafeMutablePointer<MYSQL_STMT>!
    private var bindings: UnsafeMutablePointer<MYSQL_BIND>!
    private var columnsCount: Int {
        return Int(mysql_stmt_field_count(self.statement))
    }

    public var errorMessage: String {
        return "\(mysql_error(mysql))"
    }
    
    deinit {
        close()
    }
    
    public init(username: String, password: String, host: String, database: String, port: UInt = 3306, flag: UInt = 0) throws {
        if mysql == nil {
            mysql = mysql_init(nil)
        }
        
        let connection = mysql_real_connect(mysql, host, username, password, database, UInt32(port), nil, flag)
        if connection == nil {
            throw MySQLError.NoConnection
        }

    }
    
    public init(username: String, password: String, database: String, socket: String, flag: UInt = 0) throws {
        if mysql == nil {
            mysql = mysql_init(nil)
        }
        
        let connection = mysql_real_connect(mysql, nil, username, password, database, 0, socket, flag)
        if connection == nil {
            throw MySQLError.NoConnection
        }
    }
    
    public func close() {
        if let statement = self.statement {
            mysql_stmt_close(statement)
        }
        if let mysql = mysql {
            mysql_close(mysql)
        }
    }
    
    public func execute(query: String) throws -> [[String: String]] {
        guard mysql_query(mysql, query) == 0 else {
            throw MySQLError.BadSQL
        }
        
        let result = mysql_use_result(mysql)
        
        if mysql_errno(mysql) > 0 {
            throw MySQLError.BadSQL
        }
        
        var results = [[String: String]]()
        var row = mysql_fetch_row(result)
        repeat {
            for (index, columnField) in columns(result).enumerated() {
                results.append([columnField: String(cString: row[index])])
            }
            row = mysql_fetch_row(result)
        } while row != nil
        
        defer { mysql_free_result(result) }
        return results
    }
    
    public func execute(query: String, bindHandler: BindHandler) throws -> [[String: String]]  {
        guard mysql_stmt_prepare(statement, query, UInt(query.characters.count)) == 0 else {
            throw MySQLError.BadSQL
        }
        
        bindings = UnsafeMutablePointer<MYSQL_BIND>(allocatingCapacity: 1)
        
        for i in 0..<Int(mysql_stmt_param_count(statement)) {
            bindings.advanced(by: i).initialize(with: MYSQL_BIND())
        }
        
        try bindHandler()
        
        guard mysql_stmt_bind_param(statement, bindings) == 0 else {
            throw MySQLError.BadSQL
        }
        
        guard mysql_stmt_execute(statement) == 0 else {
            throw MySQLError.BadSQL
        }
        
        let resultMeta = mysql_stmt_result_metadata(self.statement)
        let resultsBind = getResultsBind(resultMeta)
        
        guard mysql_stmt_bind_result(self.statement, resultsBind) == 0 else {
            throw MySQLError.UnableToBindResults
        }
        
        let rows = try getRows(fromResultsBind: resultsBind, resultMeta: resultMeta)
        defer { clearResultsBind(resultsBind) }
        return mapToColumns(resultMeta, rows: rows)
    }
    
    func bind(value: String, position: Int) {
        self.bindings[position].buffer_type = MYSQL_TYPE_STRING
        self.bindings[position].buffer_length = UInt(sizeof(String))
        let a = UnsafeMutablePointer<String>(allocatingCapacity: 1)
        a.initialize(with: value)
        self.bindings[position].buffer = UnsafeMutablePointer<Void>(a)
    }
    
    func bindNull(position: Int) {
        self.bindings[position].buffer_type = MYSQL_TYPE_NULL
        self.bindings[position].length = UnsafeMutablePointer<UInt>(allocatingCapacity: 1)
    }
    
    func bind(value: Int32, position: Int) {
        self.bindings[position].buffer_type = MYSQL_TYPE_LONGLONG
        self.bindings[position].buffer_length = UInt(sizeof(Int32))
        let a = UnsafeMutablePointer<Int32>(allocatingCapacity: 1)
        a.initialize(with: value)
        self.bindings[position].buffer = UnsafeMutablePointer<Void>(a)
    }
    
    func bind(value: Int64, position: Int) {
        self.bindings[position].buffer_type = MYSQL_TYPE_LONGLONG
        self.bindings[position].buffer_length = UInt(sizeof(Int64))
        let a = UnsafeMutablePointer<Int64>(allocatingCapacity: 1)
        a.initialize(with: value)
        self.bindings[position].buffer = UnsafeMutablePointer<Void>(a)
    }
    
    func bind(value: Double, position: Int) {
        self.bindings[position].buffer_type = MYSQL_TYPE_DOUBLE
        self.bindings[position].buffer_length = UInt(sizeof(Double))
        let a = UnsafeMutablePointer<Double>(allocatingCapacity: 1)
        a.initialize(with: value)
        self.bindings[position].buffer = UnsafeMutablePointer<Void>(a)
    }
    
    func resultValueType(forFieldType type: enum_field_types) -> FieldType {
        switch type {
        case MYSQL_TYPE_FLOAT:
            return .Float
        case MYSQL_TYPE_DOUBLE:
            return .Double
        case MYSQL_TYPE_TINY:
            return .Tiny
        case MYSQL_TYPE_SHORT:
            return .Short
        case MYSQL_TYPE_LONG, MYSQL_TYPE_INT24:
            return .Long
        case MYSQL_TYPE_LONGLONG:
            return .LongLong
        case MYSQL_TYPE_TIMESTAMP, MYSQL_TYPE_DATE, MYSQL_TYPE_TIME, MYSQL_TYPE_DATETIME, MYSQL_TYPE_YEAR, MYSQL_TYPE_NEWDATE:
            return .Date
        case MYSQL_TYPE_NULL, MYSQL_TYPE_TINY_BLOB, MYSQL_TYPE_MEDIUM_BLOB, MYSQL_TYPE_LONG_BLOB, MYSQL_TYPE_BLOB:
            return .Data
        default:
            return .String
        }
    }
    
    func resultBind(forFieldType type: enum_field_types, unsigned: Bool) -> MYSQL_BIND {
        var bind = MYSQL_BIND()
        switch type {
        case MYSQL_TYPE_FLOAT:
            bind.buffer = UnsafeMutablePointer<Void>(UnsafeMutablePointer<Float>(allocatingCapacity: 1))
            bind.buffer_length = UInt(sizeof(Float))
        case MYSQL_TYPE_DOUBLE:
            bind.buffer = UnsafeMutablePointer<Void>(UnsafeMutablePointer<Double>(allocatingCapacity: 1))
            bind.buffer_length = UInt(sizeof(Double))
        case MYSQL_TYPE_TINY:
            if unsigned {
                bind.buffer = UnsafeMutablePointer<Void>(UnsafeMutablePointer<CUnsignedChar>(allocatingCapacity: 1))
                bind.buffer_length = UInt(sizeof(CUnsignedChar))
            } else {
                bind.buffer = UnsafeMutablePointer<Void>(UnsafeMutablePointer<CChar>(allocatingCapacity: 1))
                bind.buffer_length = UInt(sizeof(CChar))
            }
        case MYSQL_TYPE_SHORT:
            if unsigned {
                bind.buffer = UnsafeMutablePointer<Void>(UnsafeMutablePointer<CUnsignedShort>(allocatingCapacity: 1))
                bind.buffer_length = UInt(sizeof(CUnsignedShort))
            } else {
                bind.buffer = UnsafeMutablePointer<Void>(UnsafeMutablePointer<CShort>(allocatingCapacity: 1))
                bind.buffer_length = UInt(sizeof(CShort))
            }
        case MYSQL_TYPE_LONG, MYSQL_TYPE_INT24:
            if unsigned {
                bind.buffer = UnsafeMutablePointer<Void>(UnsafeMutablePointer<CUnsignedInt>(allocatingCapacity: 1))
                bind.buffer_length = UInt(sizeof(CUnsignedInt))
            } else {
                bind.buffer = UnsafeMutablePointer<Void>(UnsafeMutablePointer<CInt>(allocatingCapacity: 1))
                bind.buffer_length = UInt(sizeof(CInt))
            }
        case MYSQL_TYPE_LONGLONG:
            if unsigned {
                bind.buffer = UnsafeMutablePointer<Void>(UnsafeMutablePointer<CUnsignedLongLong>(allocatingCapacity: 1))
                bind.buffer_length = UInt(sizeof(CUnsignedLongLong))
            } else {
                bind.buffer = UnsafeMutablePointer<Void>(UnsafeMutablePointer<CLongLong>(allocatingCapacity: 1))
                bind.buffer_length = UInt(sizeof(CLongLong))
            }
        case MYSQL_TYPE_TIMESTAMP, MYSQL_TYPE_DATE, MYSQL_TYPE_TIME, MYSQL_TYPE_DATETIME, MYSQL_TYPE_YEAR, MYSQL_TYPE_NEWDATE:
            bind.buffer = UnsafeMutablePointer<Void>(UnsafeMutablePointer<Int8>(allocatingCapacity: 0))
            bind.buffer_length = 0
        case MYSQL_TYPE_NULL, MYSQL_TYPE_TINY_BLOB, MYSQL_TYPE_MEDIUM_BLOB, MYSQL_TYPE_LONG_BLOB, MYSQL_TYPE_BLOB:
            bind.buffer = UnsafeMutablePointer<Void>(UnsafeMutablePointer<Int8>(allocatingCapacity: 0))
            bind.buffer_length = 0
        default:
            bind.buffer = UnsafeMutablePointer<Void>(UnsafeMutablePointer<String>(allocatingCapacity: 1))
            bind.buffer_length = UInt(sizeof(String))
        }

        return bind
    }
    
    func columns(result: UnsafeMutablePointer<MYSQL_RES>) -> [String] {
        var _columns = [String]()
        let columnsFields = mysql_fetch_fields(result)
        for i in 0..<Int(mysql_num_fields(result)) {
            _columns.append(String(cString:columnsFields[i].name))
        }
        return _columns
    }
    
    func value<T>(fromBind bind: MYSQL_BIND, type: T) -> T {
        return UnsafeMutablePointer<T>(bind.buffer).pointee
    }
    
    func mapToColumns(resultMeta: UnsafeMutablePointer<MYSQL_RES>, rows: [Any?]) -> [[String: String]] {
        var results = [[String: String]]()
        var row = mysql_fetch_row(resultMeta)
        repeat {
            for (index, columnField) in columns(resultMeta).enumerated() {
                results.append([columnField: String(cString: row[index])])
            }
            row = mysql_fetch_row(resultMeta)
        } while row != nil
        
        defer { mysql_free_result(resultMeta) }
        return results
    }
    
    func getRows(fromResultsBind binds: UnsafeMutablePointer<MYSQL_BIND>, resultMeta: UnsafeMutablePointer<MYSQL_RES>) throws -> [Any?] {
        var rows = [Any?]()
        while true {
            let fetchRes = mysql_stmt_fetch(self.statement)
            if fetchRes == MYSQL_NO_DATA {
                break
            }
            
            if fetchRes == 1 {
                throw MySQLError.BadSQL
            }
            
            for i in 0..<columnsCount {
                let bind = binds[i]
                let isNull = bind.is_null.pointee
                //let length = bind.length.pointee
                let type = resultValueType(forFieldType: bind.buffer_type)
                
                if isNull != 0 {
                    rows.append(nil)
                } else {
                    switch type {
                    case .Null:
                        rows.append(nil)
                    case .Float:
                        rows.append(value(fromBind: bind, type: Float.self))
                    case .Double:
                        rows.append(value(fromBind: bind, type: Double.self))
                    case .Tiny:
                        if bind.is_unsigned == 1 {
                            rows.append(value(fromBind: bind, type: CUnsignedChar.self))
                        } else {
                            rows.append(value(fromBind: bind, type: CChar.self))
                        }
                    case .Long:
                        if bind.is_unsigned == 1 {
                            rows.append(value(fromBind: bind, type: CUnsignedInt.self))
                        } else {
                            rows.append(value(fromBind: bind, type: CInt.self))
                        }
                    case .LongLong:
                        if bind.is_unsigned == 1 {
                            rows.append(value(fromBind: bind, type: CUnsignedLongLong.self))
                        } else {
                            rows.append(value(fromBind: bind, type: CLongLong.self))
                        }
                    case .String, .Date:
                        rows.append(value(fromBind: bind, type: String.self))
                    case .Data:
                        //                        let raw = UnsafeMutablePointer<UInt8>(allocatingCapacity: Int(length))
                        //                        defer { raw.deallocateCapacity(Int(length)) }
                        //                        bind.buffer = UnsafeMutablePointer<()>(raw)
                        //                        bind.buffer_length = UInt(length)
                        //
                        //                        let res = mysql_stmt_fetch_column(self.statement, &bind, UInt32(i), 0)
                        //                        guard res == 0 else { break }
                        //
                        //                        var a = [UInt8]()
                        //                        var gen = GenerateFromPointer(from: raw, count: length)
                        //                        while let c = gen.next() {
                        //                            a.append(c)
                        //                        }
                        //                        rows.append(a)
                        break
                    default:
                        break
                    }
                }
            }
        }
        return rows
    }
    
    func getResultsBind(meta: UnsafeMutablePointer<MYSQL_RES>) -> UnsafeMutablePointer<MYSQL_BIND> {
        let resultsBinder = UnsafeMutablePointer<MYSQL_BIND>(allocatingCapacity: columnsCount)
        let lengthBuffers = UnsafeMutablePointer<UInt>(allocatingCapacity: columnsCount)
        let isNullBuffers = UnsafeMutablePointer<my_bool>(allocatingCapacity: columnsCount)
        
        for i in 0..<columnsCount {
            let field = mysql_fetch_field_direct(meta, UInt32(i)).pointee
            let unsigned = field.flags == UInt32(UNSIGNED_FLAG)
            
            var bind = resultBind(forFieldType: field.type, unsigned: unsigned)
            bind.length = lengthBuffers.advanced(by: i)
            bind.length.initialize(with: 0)
            bind.is_null = isNullBuffers.advanced(by: i)
            bind.is_null.initialize(with: 0)
            
            resultsBinder.advanced(by: i).initialize(with: bind)
        }
        
        defer {
            lengthBuffers.deallocateCapacity(columnsCount)
            isNullBuffers.deallocateCapacity(columnsCount)
        }
        return resultsBinder
    }
    
    func clearResultsBind(binder: UnsafeMutablePointer<MYSQL_BIND>) {
        for i in 0..<columnsCount {
            let bind = binder[i]
            bind.buffer.deallocateCapacity(1)
        }
    }
}
