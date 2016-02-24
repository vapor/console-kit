#if os(Linux)
    import CMySQLLinux
#else
    import CMySQLMac
#endif

public class MySQL {
  private var mysql: COpaquePointer!

  public var errorMessage: String {
    return "\(mysql_error(_mysql))"
  }

  public var connected: Bool {
    return mysql_stat(_mysql) ? true : false
  }

  public var autoincrementID: Int {
    return mysql_insert_id(_mysql)
  }

  public init() {
    if mysql_library_init(0, nil, nil) {

    }
  }

  deinit {
    close()
    finalize()
  }

  public func execute(query: String) -> MSQLResult? {
    if !mysql_query(mysql, query) {
      let result = mysql_use_result(mysql)
      return MSQLResult(result)
    }

    // if mysql_errno(mysql) {
    //   print(errorMessage)
		// }

    return nil
  }

  public func finalize() {
    mysql_library_end()
  }

  public func close() {
    if let mysql = mysql {
      mysql_close(mysql)
    }
  }

  public func connect(username: String, password: String, database: String, host: String? = nil, port: Int? = 0, socket: String? = nil, flag: Int = 0) -> Bool {
    if mysql == nil {
      mysql = mysql_init(nil)
    }

    if !mysql_real_connect(mysql, host, username, password, database, port, socket, flag) {
      mysql_close(mysql)
      return false
    }

  	// if !mysql_set_character_set(_mysql, "utf8") {
  	// 	print("mysql: character set is \(mysql_character_set_name(mysql)).")
  	// }
    return true
  }
}

class MSQLResult {
  private var result: COpaquePointer!

  public lazy var columns: [String]? = { [unowned self] in
    guard let result = result else { return nil }
    if self.columns.isEmpty {
      let _columns = [String]()
      let columnsFields = mysql_fetch_fields(result)
      for i in 0..<self.columnCount {
          _columns.append(columnsFields[i])
      }
      return _columns
    }
    return self.columns
  }()

  public lazy var rowCount: Int = {
      return Int(mysql_num_rows(self.internalPointer))
  }()

  public lazy var columnCount: Int = {
      return Int(mysql_num_fields(self.internalPointer))
  }()

  public init(result: COpaquePointer) {
    self.result = result
  }

  deinit {
      mysql_free_result(result)
  }

  public func affectedRow() -> [[String: String]]? {
    let data = [[String: String]]()
    var rowP: COpaquePointer? 
    repeat {  
      rowP = mysql_fetch_row(result)
      for columnField in columns {
          data[columnField.name] = rowP![columnField.index]
      }
    } while rowP != nil 
    defer { mysql_free_result(result) }
    return data
  }
}
