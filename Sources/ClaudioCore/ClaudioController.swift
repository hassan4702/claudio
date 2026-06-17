import Foundation

/// Orchestrates the app's behavior over Core services. UI binds to this.
public final class ClaudioController {
    public let settings: SettingsManager
    public let library: SoundLibrary
    public let prefs: Preferences

    public init(settings: SettingsManager, library: SoundLibrary, prefs: Preferences) {
        self.settings = settings
        self.library = library
        self.prefs = prefs
    }

    /// Whether Claude Code's settings file was found.
    public var claudeCodeInstalled: Bool { settings.settingsFileExists() }

    /// A sensible default source sound for an event.
    public func defaultSource(for event: ClaudioEvent) -> URL {
        let name: String
        switch event {
        case .done: name = "Glass"
        case .needsInput: name = "Submarine"
        }
        return URL(fileURLWithPath: "/System/Library/Sounds/\(name).aiff")
    }

    /// Turn Claudio on: ensure both events have an active sound copy and a hook.
    public func enableAll() throws {
        for event in ClaudioEvent.allCases {
            let source = library.activeSoundURL(for: event) ?? defaultSource(for: event)
            try setSound(source, for: event, writeHook: true)
        }
        prefs.enabled = true
    }

    /// Turn Claudio off: remove both hooks (sound files and prefs are kept).
    public func disableAll() throws {
        for event in ClaudioEvent.allCases {
            try settings.disable(event: event)
        }
        prefs.enabled = false
    }

    /// Change the sound for an event: copy it into place and, if `writeHook`,
    /// rewrite the hook to point at the new file.
    public func setSound(_ source: URL, for event: ClaudioEvent, writeHook: Bool) throws {
        let dest = try library.setActiveSound(from: source, for: event)
        prefs.setSelectedSoundName(
            source.deletingPathExtension().lastPathComponent, for: event)
        if writeHook {
            try settings.enable(
                event: event, command: HookBuilder.command(forSoundAt: dest.path))
        }
    }
}
