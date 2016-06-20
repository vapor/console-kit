/**
    Represents the various types of data that MySQL
    rows can contain and that will be returned by the Database.
*/
public enum Value {
    case string(String)
    case int(Int)
    case uint(UInt)
    case double(Double)
    case null
}
