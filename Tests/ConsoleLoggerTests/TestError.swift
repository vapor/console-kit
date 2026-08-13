struct TestError: Error, CustomStringConvertible {
    var description: String {
        "Something went wrong!"
    }
}
