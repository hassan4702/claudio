import XCTest
@testable import ClaudioCore

final class ClaudioControllerTests: XCTestCase {
    var dir: URL!
    var controller: ClaudioController!
    var settings: SettingsManager!
    var marker: String!
    var suiteName: String!

    override func setUpWithError() throws {
        dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("claudio-ctrl-" + UUID().uuidString)
        let appSupport = dir.appendingPathComponent("Claudio")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        marker = appSupport.path
        let settingsURL = dir.appendingPathComponent("settings.json")
        try "{}".data(using: .utf8)!.write(to: settingsURL)
        settings = SettingsManager(
            settingsURL: settingsURL,
            backupURL: dir.appendingPathComponent("backup.json"),
            marker: marker)
        suiteName = "claudio.ctrl." + UUID().uuidString
        let prefs = Preferences(defaults: UserDefaults(suiteName: suiteName)!)
        controller = ClaudioController(
            settings: settings,
            library: SoundLibrary(appSupport: appSupport),
            prefs: prefs)
    }

    override func tearDownWithError() throws {
        UserDefaults().removePersistentDomain(forName: suiteName)
        try? FileManager.default.removeItem(at: dir)
    }

    func testEnableAllWritesBothHooksPointingAtCopies() throws {
        try controller.enableAll()
        XCTAssertTrue(try settings.isEnabled(event: .done))
        XCTAssertTrue(try settings.isEnabled(event: .needsInput))
        XCTAssertTrue(controller.prefs.enabled)
        // The copies exist and the command references them (via the marker).
        XCTAssertNotNil(controller.library.activeSoundURL(for: .done))
        let root = try settings.readRoot()
        let groups = (root["hooks"] as? [String: Any])?["Stop"] as? [Any]
        let hook = ((groups?.first as? [String: Any])?["hooks"] as? [Any])?.first as? [String: Any]
        XCTAssertTrue((hook?["command"] as? String)?.contains(marker) == true)
    }

    func testDisableAllRemovesHooks() throws {
        try controller.enableAll()
        try controller.disableAll()
        XCTAssertFalse(try settings.isEnabled(event: .done))
        XCTAssertFalse(try settings.isEnabled(event: .needsInput))
        XCTAssertFalse(controller.prefs.enabled)
    }

    func testReEnableAfterDisableReusesExistingSound() throws {
        try controller.enableAll()
        try controller.disableAll()
        // Toggling back on must not throw and must restore both hooks.
        XCTAssertNoThrow(try controller.enableAll())
        XCTAssertTrue(try settings.isEnabled(event: .done))
        XCTAssertTrue(try settings.isEnabled(event: .needsInput))
        // The chosen sound name is preserved across the cycle (not corrupted to the file stem).
        XCTAssertEqual(controller.prefs.selectedSoundName(for: .done), "Glass")
        XCTAssertEqual(controller.prefs.selectedSoundName(for: .needsInput), "Submarine")
    }

    func testSetSoundWhileEnabledUpdatesHookPath() throws {
        try controller.enableAll()
        let ping = URL(fileURLWithPath: "/System/Library/Sounds/Ping.aiff")
        try controller.setSound(ping, for: .done, writeHook: true)
        let root = try settings.readRoot()
        let groups = (root["hooks"] as? [String: Any])?["Stop"] as? [Any]
        let hook = ((groups?.first as? [String: Any])?["hooks"] as? [Any])?.first as? [String: Any]
        XCTAssertTrue((hook?["command"] as? String)?.contains("done.aiff") == true)
        XCTAssertEqual(controller.prefs.selectedSoundName(for: .done), "Ping")
    }

    func testRestoreBackupRevertsAndDisables() throws {
        try controller.enableAll()
        XCTAssertTrue(controller.hasBackup)
        try controller.restoreBackup()
        XCTAssertFalse(try settings.isEnabled(event: .done))
        XCTAssertFalse(try settings.isEnabled(event: .needsInput))
        XCTAssertFalse(controller.prefs.enabled)
    }
}
