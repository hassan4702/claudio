import XCTest
@testable import ClaudioCore

final class ClaudioEventTests: XCTestCase {
    func testSettingsKeyMapping() {
        XCTAssertEqual(ClaudioEvent.done.settingsKey, "Stop")
        XCTAssertEqual(ClaudioEvent.needsInput.settingsKey, "Notification")
    }

    func testFileStems() {
        XCTAssertEqual(ClaudioEvent.done.fileStem, "done")
        XCTAssertEqual(ClaudioEvent.needsInput.fileStem, "needs-input")
    }

    func testAllCasesCount() {
        XCTAssertEqual(ClaudioEvent.allCases.count, 2)
    }
}
