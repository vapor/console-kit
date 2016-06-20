#if os(Linux)
    import CMySQLLinux
#else
    import CMySQLMac
#endif

/**
    This structure represents a handle to one database connection.
    It is used for almost all MySQL functions.
    Do not try to make a copy of a MYSQL structure.
    There is no guarantee that such a copy will be usable.
*/
public final class Connection {

    public typealias CConnection = UnsafeMutablePointer<MYSQL>

    public let cConnection: CConnection

    public init(
        host: String,
        user: String,
        password: String,
        database: String,
        port: UInt32,
        socket: String?,
        flag: UInt
    ) throws {
        cConnection = mysql_init(nil)

        guard mysql_real_connect(cConnection, host, user, password, database, port, socket, flag) != nil else {
            throw Database.Error.connection(error)
        }
    }

    deinit {
        mysql_close(cConnection)
        mysql_thread_end()
    }

    /**
        Contains the last error message generated
        by this MySQLS connection.
    */
    public var error: String {
        guard let error = mysql_error(cConnection) else {
            return "Unknown"
        }
        return String(cString: error)
    }
    
}

