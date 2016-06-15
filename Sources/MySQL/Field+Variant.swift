#if os(Linux)
    import CMySQLLinux
#else
    import CMySQLMac
#endif

extension Field {
    /**
        The various types of fields MySQL is
        capable of storing.
    */
    public typealias Variant = enum_field_types
}

extension Field.Variant: CustomStringConvertible {
    /**
        A readable representation
        of the Field variant.
    */
    public var description: String {
        switch self {
        case MYSQL_TYPE_TINY:
            return "TINYINT field"
        case MYSQL_TYPE_SHORT:
            return "SMALLINT field"
        case MYSQL_TYPE_LONG:
            return "INTEGER field"
        case MYSQL_TYPE_INT24:
            return "MEDIUMINT field"
        case MYSQL_TYPE_LONGLONG:
            return "BIGINT field"
        case MYSQL_TYPE_DECIMAL:
            return "DECIMAL or NUMERIC field"
        case MYSQL_TYPE_NEWDECIMAL:
            return "Precision math DECIMAL or NUMERIC"
        case MYSQL_TYPE_FLOAT:
            return "FLOAT field"
        case MYSQL_TYPE_DOUBLE:
            return "DOUBLE or REAL field"
        case MYSQL_TYPE_BIT:
            return "BIT field"
        case MYSQL_TYPE_TIMESTAMP:
            return "TIMESTAMP field"
        case MYSQL_TYPE_DATE:
            return "DATE field"
        case MYSQL_TYPE_TIME:
            return "TIME field"
        case MYSQL_TYPE_DATETIME:
            return "DATETIME field"
        case MYSQL_TYPE_YEAR:
            return "YEAR field"
        case MYSQL_TYPE_STRING:
            return "CHAR or BINARY field"
        case MYSQL_TYPE_VAR_STRING:
            return "VARCHAR or VARBINARY field"
        case MYSQL_TYPE_BLOB:
            return "BLOB or TEXT field (use max_length to determine the maximum length)"
        case MYSQL_TYPE_SET:
            return "SET field"
        case MYSQL_TYPE_ENUM:
            return "ENUM field"
        case MYSQL_TYPE_GEOMETRY:
            return "Spatial field"
        case MYSQL_TYPE_NULL:
            return "NULL-type field"
        default:
            return "unknown"
        }
    }
}
