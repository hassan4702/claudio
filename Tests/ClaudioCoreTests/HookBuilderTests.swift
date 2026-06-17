import XCTest
@testable import ClaudioCore

final class HookBuilderTests: XCTestCase {
    func testCommandWrapsPathInAfplay() {
        let cmd = HookBuilder.command(forSoundAt: "/tmp/Claudio/done.aiff")
        XCTAssertEqual(cmd, "afplay \"/tmp/Claudio/done.aiff\"")
    }

    func testHookGroupShape() {
        let group = HookBuilder.hookGroup(command: "afplay \"/x.aiff\"")
        let hooks = group["hooks"] as? [[String: Any]]
        XCTAssertEqual(hooks?.count, 1)
        XCTAssertEqual(hooks?.first?["type"] as? String, "command")
        XCTAssertEqual(hooks?.first?["command"] as? String, "afplay \"/x.aiff\"")
        XCTAssertEqual(hooks?.first?["async"] as? Bool, true)
    }
}
