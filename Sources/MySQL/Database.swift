#if os(Linux)
    import CMySQLLinux
#else
    import CMySQLMac
#endif

public class Database {
    public typealias FieldType = enum_field_types

    public enum Error: ErrorProtocol {
        case connection(String)
        case query(String)
        case inputBind(String)
        case fetchFields(String)
        case prepare(String)
        case statement(String)
        case fieldFetch
        case escape
    }

    typealias Statement = UnsafeMutablePointer<MYSQL_STMT>
    typealias Connection = UnsafeMutablePointer<MYSQL>

    let connection: Connection

    public init(
        username: String,
        password: String,
        host: String,
        database: String,
        port: UInt32 = 3306,
        socket: String? = nil,
        flag: UInt = 0
    ) throws {
        connection = mysql_init(nil)

        guard mysql_real_connect(connection, host, username, password, database, port, socket, flag) != nil else {
            throw Error.connection(errorMessage)
        }
    }

    @discardableResult
    public func execute(_ query: String, _ values: [Value] = []) throws -> [[String: Value]] {
        guard let statement = mysql_stmt_init(connection) else {
            throw Error.statement(errorMessage)
        }

        guard mysql_stmt_prepare(statement, query, strlen(query)) == 0 else {
            throw Error.prepare(errorMessage)
        }

        let inputBinds = Binds(values)
        guard mysql_stmt_bind_param(statement, inputBinds.cBinds) == 0 else {
            throw Error.inputBind(errorMessage)
        }


        if let metadata = mysql_stmt_result_metadata(statement) {

            let fields: Fields
            do {
                fields = try Fields(metadata)
            } catch {
                throw Error.fetchFields(errorMessage)
            }

            let outputBinds = Binds(fields)

            mysql_stmt_bind_result(statement, outputBinds.cBinds)
            mysql_stmt_execute(statement)

            var results: [[String: Value]] = []

            while mysql_stmt_fetch(statement) == 0 {
                var parsed: [String: Value] = [:]

                for (i, field) in fields.fields.enumerated() {
                    let output = outputBinds[i]

                    parsed[field.name] = output.value
                }

                results.append(parsed)
                mysql_stmt_bind_result(statement, outputBinds.cBinds)
            }

            return results
        } else {
            mysql_stmt_execute(statement)
            return []
        }
    }

    public var errorMessage: String {
        guard let error = mysql_error(connection) else {
            return "Unknown"
        }
        return String(cString: error)
    }
    
    deinit {
        close()
    }

    public func close() {
        mysql_close(connection)
    }

}
