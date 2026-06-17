import XCTest
@testable import ClaudioCore

final class SettingsManagerTests: XCTestCase {
    var dir: URL!
    var settingsURL: URL!
    var backupURL: URL!
    var marker: String!
    var manager: SettingsManager!

    override func setUpWithError() throws {
        dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("claudio-tests-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        settingsURL = dir.appendingPathComponent("settings.json")
        backupURL = dir.appendingPathComponent("backup/settings.backup.json")
        marker = dir.appendingPathComponent("Claudio").path
        manager = SettingsManager(settingsURL: settingsURL, backupURL: backupURL, marker: marker)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: dir)
    }

    func testEmptyFileReturnsEmpty() throws {
        try Data().write(to: settingsURL)
        XCTAssertTrue(manager.settingsFileExists())
        XCTAssertTrue(try manager.readRoot().isEmpty)
    }

    func testReadMissingFileReturnsEmpty() throws {
        XCTAssertFalse(manager.settingsFileExists())
        XCTAssertTrue(try manager.readRoot().isEmpty)
    }

    func testInvalidJSONThrows() throws {
        try "not json".data(using: .utf8)!.write(to: settingsURL)
        XCTAssertThrowsError(try manager.readRoot()) { error in
            XCTAssertEqual(error as? SettingsManager.ConfigError, .invalidJSON)
        }
    }

    func testEnableThenDisableRoundTrips() throws {
        try #"{"model":"opus"}"#.data(using: .utf8)!.write(to: settingsURL)
        let cmd = HookBuilder.command(forSoundAt: marker + "/done.aiff")
        try manager.enable(event: .done, command: cmd)
        XCTAssertTrue(try manager.isEnabled(event: .done))

        try manager.disable(event: .done)
        XCTAssertFalse(try manager.isEnabled(event: .done))
        // Original key still present.
        XCTAssertEqual(try manager.readRoot()["model"] as? String, "opus")
    }

    func testWriteCreatesBackup() throws {
        try #"{"model":"opus"}"#.data(using: .utf8)!.write(to: settingsURL)
        let cmd = HookBuilder.command(forSoundAt: marker + "/done.aiff")
        try manager.enable(event: .done, command: cmd)
        XCTAssertTrue(FileManager.default.fileExists(atPath: backupURL.path))
    }

    func testBackupCapturesPristineOriginalNotLaterWrites() throws {
        try #"{"model":"opus"}"#.data(using: .utf8)!.write(to: settingsURL)
        let cmd = HookBuilder.command(forSoundAt: marker + "/done.aiff")
        try manager.enable(event: .done, command: cmd)   // write 1 -> backup = pristine original
        try manager.disable(event: .done)                // write 2 -> must NOT overwrite backup
        let backupData = try Data(contentsOf: backupURL)
        let backupObj = try JSONSerialization.jsonObject(with: backupData) as? [String: Any]
        XCTAssertEqual(backupObj?["model"] as? String, "opus")
        XCTAssertNil(backupObj?["hooks"], "backup must be the pristine pre-Claudio file (no Claudio hooks)")
    }
}
