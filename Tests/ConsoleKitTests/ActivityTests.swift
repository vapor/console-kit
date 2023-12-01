@testable import ConsoleKitTerminal
import XCTest

final class ActivityTests: XCTestCase {
    func testActivityWidthKey() {
        var dict = [AnySendableHashable: String]()
        
        dict[AnySendableHashable(ActivityBarWidthKey())] = "width key"
        dict[AnySendableHashable("ConsoleKit.ActivityBarWidthKey")] = "string key"
        
        XCTAssertEqual(dict[AnySendableHashable(ActivityBarWidthKey())], "width key")
        XCTAssertEqual(dict[AnySendableHashable("ConsoleKit.ActivityBarWidthKey")],  "string key")
    }
}
