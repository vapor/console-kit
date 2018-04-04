@_exported import Core
@_exported import Service

// add to core
extension Thread {
    public static func async(work: @escaping () -> Void) {
        if #available(OSX 10.12, *) {
            Thread.detachNewThread(work)
        } else {
            fatalError("macOS 10.12 or later required")
        }
    }
}
