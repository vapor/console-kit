@testable import ConsoleKit
import Testing

@Suite("Activity Tests")
struct ActivityTests {
    @Test("Activity Width Key")
    func activityWidthKey() {
        var dict = [AnySendableHashable: String]()
        
        dict[AnySendableHashable(ActivityBarWidthKey())] = "width key"
        dict[AnySendableHashable("ConsoleKit.ActivityBarWidthKey")] = "string key"
        
        #expect(dict[AnySendableHashable(ActivityBarWidthKey())] == "width key")
        #expect(dict[AnySendableHashable("ConsoleKit.ActivityBarWidthKey")] == "string key")
    }
}
