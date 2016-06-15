#if os(Linux)
    import CMySQLLinux
#else
    import CMySQLMac
#endif

/**
    Holds a `Connection` to the MySQL database.
*/
public class Database {
    public typealias Connection = UnsafeMutablePointer<MYSQL>

    /**
        A list of all Error messages that
        can be thrown from calls to `Database`.
     
        All Error objects contain a String which
        contains MySQL's last error message.
    */
    public enum Error: ErrorProtocol {
        case connection(String)
        case inputBind(String)
        case outputBind(String)
        case fetchFields(String)
        case prepare(String)
        case statement(String)
        case execute(String)
    }


    /**
        This structure represents a handle to one database connection. 
        It is used for almost all MySQL functions.
        Do not try to make a copy of a MYSQL structure. 
        There is no guarantee that such a copy will be usable.
    */
    public let connection: Connection

    /**
        Attempts to establish a connection to a MySQL database
        engine running on host.
     
        - parameter host: May be either a host name or an IP address.
            If host is NULL or the string "localhost", a connection to the local host is assumed.
        - parameter user: The user's MySQL login ID.
        - parameter password: Password for user.
        - parameter database: Database name. 
            If db is not NULL, the connection sets the default database to this value.
        - parameter port: If port is not 0, the value is used as 
            the port number for the TCP/IP connection.
        - parameter socket: If socket is not NULL, 
            the string specifies the socket or named pipe to use.
        - parameter flag: Usually 0, but can be set to a combination of the 
            flags at http://dev.mysql.com/doc/refman/5.7/en/mysql-real-connect.html


        - throws: `Error.connection(String)` if the call to
            `mysql_real_connect()` fails.

    */
    public init(
        host: String = "localhost",
        user: String,
        password: String,
        database: String?,
        port: UInt32 = 3306,
        socket: String? = nil,
        flag: UInt = 0
    ) throws {
        connection = mysql_init(nil)

        guard mysql_real_connect(connection, host, user, password, database, port, socket, flag) != nil else {
            throw Error.connection(errorMessage)
        }
    }

    /**
        Executes the MySQL query string with parameterized values.
     
        - parameter query: MySQL flavored SQL query string.
        - parameter values: Array of MySQL values to be parameterized.
            The number of Values MUST equal the number of `?` in the query string.
     
        - throws: Various `Database.Error` types.
     
        - returns: An array of `[String: Value]` results.
            May be empty if the call does not produce data.
    */
    @discardableResult
    public func execute(_ query: String, _ values: [Value] = []) throws -> [[String: Value]] {
        // Create a pointer to the statement
        // This should only fail if memory is limited.
        guard let statement = mysql_stmt_init(connection) else {
            throw Error.statement(errorMessage)
        }

        // Prepares the created statement
        // This parses `?` in the query and
        // prepares them to attach parameterized bindings.
        guard mysql_stmt_prepare(statement, query, strlen(query)) == 0 else {
            throw Error.prepare(errorMessage)
        }

        // Transforms the `[Value]` array into bindings
        // and applies those bindings to the statement.
        let inputBinds = Binds(values)
        guard mysql_stmt_bind_param(statement, inputBinds.cBinds) == 0 else {
            throw Error.inputBind(errorMessage)
        }

        // Fetches metadata from the statement which has
        // not yet run.
        if let metadata = mysql_stmt_result_metadata(statement) {

            // Parse the fields (columns) that will be returned
            // by this statement.
            let fields: Fields
            do {
                fields = try Fields(metadata)
            } catch {
                throw Error.fetchFields(errorMessage)
            }

            // Use the fields data to create output bindings.
            // These act as buffers for the data that will
            // be returned when the statement is executed.
            let outputBinds = Binds(fields)

            // Bind the output bindings to the statement.
            guard mysql_stmt_bind_result(statement, outputBinds.cBinds) == 0 else {
                throw Error.outputBind(errorMessage)
            }

            // Execute the statement!
            // The data is ready to be fetched when this completes.
            guard mysql_stmt_execute(statement) == 0 else {
                throw Error.execute(errorMessage)
            }

            var results: [[String: Value]] = []

            // Iterate over all of the rows that are returned.
            // `mysql_stmt_fetch` will continue to return `0`
            // as long as there are rows to be fetched.
            while mysql_stmt_fetch(statement) == 0 {
                var parsed: [String: Value] = [:]

                // For each row, loop over all of the fields expected.
                for (i, field) in fields.fields.enumerated() {

                    // For each field, grab the data from
                    // the output binding buffer and add
                    // it to the parsed results.
                    let output = outputBinds[i]
                    parsed[field.name] = output.value

                }

                results.append(parsed)

                // reset the bindings onto the statement to 
                // signal that they may be reused as buffers
                // for the next row fetch.
                guard mysql_stmt_bind_result(statement, outputBinds.cBinds) == 0 else {
                    throw Error.outputBind(errorMessage)
                }
            }

            return results
        } else {
            // no data is expected to return from 
            // this query, simply execute it.
            guard mysql_stmt_execute(statement) == 0 else {
                throw Error.execute(errorMessage)
            }
            return []
        }
    }

    /**
        Contains the last error message generated
        by this MySQLS connection.
    */
    public var errorMessage: String {
        guard let error = mysql_error(connection) else {
            return "Unknown"
        }
        return String(cString: error)
    }
    
    /**
        Closes the connection to MySQL.
    */
    public func close() {
        mysql_close(connection)
    }

    deinit {
        close()
    }
}
