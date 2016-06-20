#if os(Linux)
    import CMySQLLinux
#else
    import CMySQLMac
#endif
/**
    Wraps a pointer to an array of fields
    to ensure proper freeing of allocated memory.
*/
public final class Fields {
    public typealias CMetadata = UnsafeMutablePointer<MYSQL_RES>

    public let fields: [Field]

    public enum Error: ErrorProtocol {
        case fieldFetch
    }

    /**
        Creates the array of fields from
        the metadata of a statement.
    */
    public init(_ cMetadata: CMetadata) throws {
        guard let cFields = mysql_fetch_fields(cMetadata) else {
            throw Error.fieldFetch
        }

        let fieldsCount = Int(mysql_num_fields(cMetadata))

        var fields: [Field] = []

        for i in 0 ..< fieldsCount {
            let field = Field(cFields[i])
            fields.append(field)
        }

        self.fields = fields
    }
    
}
