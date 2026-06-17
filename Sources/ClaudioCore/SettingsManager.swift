import Foundation

/// Reads and writes `settings.json`, delegating structural edits to
/// `SettingsTransformer`. Handles missing files, atomic writes, and backups.
public struct SettingsManager {
    public let settingsURL: URL
    public let backupURL: URL
    public let marker: String

    public init(settingsURL: URL, backupURL: URL, marker: String) {
        self.settingsURL = settingsURL
        self.backupURL = backupURL
        self.marker = marker
    }

    /// Points at the real Claude Code config in the user's home directory.
    public static func standard(marker: String, appSupport: URL) -> SettingsManager {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return SettingsManager(
            settingsURL: home.appendingPathComponent(".claude/settings.json"),
            backupURL: appSupport.appendingPathComponent("settings.backup.json"),
            marker: marker
        )
    }

    public enum ConfigError: Error, Equatable {
        case invalidJSON
    }

    public func settingsFileExists() -> Bool {
        FileManager.default.fileExists(atPath: settingsURL.path)
    }

    /// Reads and parses the root object. Returns `[:]` if the file is absent/empty.
    public func readRoot() throws -> [String: Any] {
        guard FileManager.default.fileExists(atPath: settingsURL.path) else { return [:] }
        let data = try Data(contentsOf: settingsURL)
        if data.isEmpty { return [:] }
        guard let obj = try? JSONSerialization.jsonObject(with: data),
              let root = obj as? [String: Any] else {
            throw ConfigError.invalidJSON
        }
        return root
    }

    /// Serializes and writes `root` atomically, after backing up the current file.
    public func write(_ root: [String: Any]) throws {
        try backupIfPossible()
        let data = try JSONSerialization.data(
            withJSONObject: root,
            options: [.prettyPrinted, .sortedKeys]
        )
        try FileManager.default.createDirectory(
            at: settingsURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: settingsURL, options: .atomic)
    }

    private func backupIfPossible() throws {
        guard FileManager.default.fileExists(atPath: settingsURL.path) else { return }
        try FileManager.default.createDirectory(
            at: backupURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        if FileManager.default.fileExists(atPath: backupURL.path) {
            try FileManager.default.removeItem(at: backupURL)
        }
        try FileManager.default.copyItem(at: settingsURL, to: backupURL)
    }

    public func enable(event: ClaudioEvent, command: String) throws {
        let updated = SettingsTransformer.enable(
            root: try readRoot(), event: event, command: command, marker: marker)
        try write(updated)
    }

    public func disable(event: ClaudioEvent) throws {
        let updated = SettingsTransformer.disable(
            root: try readRoot(), event: event, marker: marker)
        try write(updated)
    }

    public func isEnabled(event: ClaudioEvent) throws -> Bool {
        SettingsTransformer.isEnabled(root: try readRoot(), event: event, marker: marker)
    }
}
