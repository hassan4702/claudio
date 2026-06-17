import Foundation

public struct Sound: Equatable, Identifiable {
    public let name: String
    public let url: URL
    public var id: String { url.path }
    public init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
}

/// Lists available sounds and manages the active-sound copies the hooks point at,
/// inside `~/Library/Application Support/Claudio/`.
public struct SoundLibrary {
    public let appSupport: URL
    private let systemSoundsDir: URL

    public init(appSupport: URL,
                systemSoundsDir: URL = URL(fileURLWithPath: "/System/Library/Sounds")) {
        self.appSupport = appSupport
        self.systemSoundsDir = systemSoundsDir
    }

    /// The macOS system sounds (`.aiff`), sorted by name.
    public func systemSounds() -> [Sound] {
        let fm = FileManager.default
        guard let items = try? fm.contentsOfDirectory(
            at: systemSoundsDir, includingPropertiesForKeys: nil) else { return [] }
        return items
            .filter { $0.pathExtension.lowercased() == "aiff" }
            .map { Sound(name: $0.deletingPathExtension().lastPathComponent, url: $0) }
            .sorted { $0.name < $1.name }
    }

    /// Absolute URL of the active copy for `event`, if one exists.
    public func activeSoundURL(for event: ClaudioEvent) -> URL? {
        let fm = FileManager.default
        guard let items = try? fm.contentsOfDirectory(
            at: appSupport, includingPropertiesForKeys: nil) else { return nil }
        return items.first { $0.deletingPathExtension().lastPathComponent == event.fileStem }
    }

    /// Copies `source` to be the active sound for `event`, replacing any prior copy
    /// (even with a different extension). Returns the destination URL.
    @discardableResult
    public func setActiveSound(from source: URL, for event: ClaudioEvent) throws -> URL {
        let fm = FileManager.default
        try fm.createDirectory(at: appSupport, withIntermediateDirectories: true)
        if let existing = activeSoundURL(for: event) {
            try fm.removeItem(at: existing)
        }
        let ext = source.pathExtension.isEmpty ? "aiff" : source.pathExtension
        let dest = appSupport.appendingPathComponent("\(event.fileStem).\(ext)")
        try fm.copyItem(at: source, to: dest)
        return dest
    }
}
