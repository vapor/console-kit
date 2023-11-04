@testable import ConsoleKit
import XCTest

final class ActivityTests: XCTestCase {
    func testActivityWidthKey() {
        var dict = [AnyHashable: String]()
        
        dict[AnyHashable(ActivityBarWidthKey())] = "width key"
        dict[AnyHashable("ConsoleKit.ActivityBarWidthKey")] = "string key"
        
        XCTAssertEqual(dict[AnyHashable(ActivityBarWidthKey())], "width key")
        XCTAssertEqual(dict[AnyHashable("ConsoleKit.ActivityBarWidthKey")],  "string key")
    }
}
