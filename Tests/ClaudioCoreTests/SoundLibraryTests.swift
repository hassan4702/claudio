import XCTest
@testable import ClaudioCore

final class SoundLibraryTests: XCTestCase {
    var dir: URL!
    var appSupport: URL!
    var fakeSystem: URL!

    override func setUpWithError() throws {
        dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("claudio-sounds-" + UUID().uuidString)
        appSupport = dir.appendingPathComponent("Claudio")
        fakeSystem = dir.appendingPathComponent("System")
        try FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: fakeSystem, withIntermediateDirectories: true)
        for name in ["Glass.aiff", "Ping.aiff", "notes.txt"] {
            try "x".data(using: .utf8)!.write(to: fakeSystem.appendingPathComponent(name))
        }
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: dir)
    }

    func testSystemSoundsListsOnlyAiffSorted() {
        let lib = SoundLibrary(appSupport: appSupport, systemSoundsDir: fakeSystem)
        let names = lib.systemSounds().map(\.name)
        XCTAssertEqual(names, ["Glass", "Ping"])
    }

    func testSetActiveSoundCopiesAndReplaces() throws {
        let lib = SoundLibrary(appSupport: appSupport, systemSoundsDir: fakeSystem)
        let glass = fakeSystem.appendingPathComponent("Glass.aiff")
        let dest = try lib.setActiveSound(from: glass, for: .done)
        XCTAssertEqual(dest.lastPathComponent, "done.aiff")
        XCTAssertTrue(FileManager.default.fileExists(atPath: dest.path))

        // Replacing with a different extension removes the old copy.
        let wav = dir.appendingPathComponent("custom.wav")
        try "y".data(using: .utf8)!.write(to: wav)
        let dest2 = try lib.setActiveSound(from: wav, for: .done)
        XCTAssertEqual(dest2.lastPathComponent, "done.wav")
        XCTAssertFalse(FileManager.default.fileExists(atPath: dest.path),
                       "old done.aiff should be gone")
        XCTAssertEqual(lib.activeSoundURL(for: .done)?.lastPathComponent, "done.wav")
    }
}
