import XCTest
@testable import ClaudioCore

final class PreferencesTests: XCTestCase {
    var defaults: UserDefaults!
    var suiteName: String!

    override func setUpWithError() throws {
        suiteName = "claudio.tests." + UUID().uuidString
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDownWithError() throws {
        defaults.removePersistentDomain(forName: suiteName)
    }

    func testEnabledDefaultsFalseAndPersists() {
        let prefs = Preferences(defaults: defaults)
        XCTAssertFalse(prefs.enabled)
        prefs.enabled = true
        XCTAssertTrue(Preferences(defaults: defaults).enabled)
    }

    func testSelectedSoundRoundTrips() {
        let prefs = Preferences(defaults: defaults)
        XCTAssertNil(prefs.selectedSoundName(for: .done))
        prefs.setSelectedSoundName("Glass", for: .done)
        XCTAssertEqual(prefs.selectedSoundName(for: .done), "Glass")
        XCTAssertNil(prefs.selectedSoundName(for: .needsInput))
    }
}
