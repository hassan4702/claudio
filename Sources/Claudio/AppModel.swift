import SwiftUI
import AppKit
import ClaudioCore

@MainActor
final class AppModel: ObservableObject {
    @Published var enabled = false
    @Published var claudeInstalled = true
    @Published var systemSounds: [Sound] = []
    @Published var selected: [ClaudioEvent: String] = [:]
    @Published var lastError: String?

    private let controller: ClaudioController

    init() {
        let appSupport = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Claudio")
        let marker = appSupport.path
        controller = ClaudioController(
            settings: .standard(marker: marker, appSupport: appSupport),
            library: SoundLibrary(appSupport: appSupport),
            prefs: Preferences())
        refresh()
    }

    func refresh() {
        claudeInstalled = controller.claudeCodeInstalled
        systemSounds = controller.library.systemSounds()
        enabled = controller.prefs.enabled
        for event in ClaudioEvent.allCases {
            selected[event] = controller.prefs.selectedSoundName(for: event)
        }
    }

    func toggle(_ on: Bool) {
        do {
            if on { try controller.enableAll() } else { try controller.disableAll() }
            refresh()
        } catch { lastError = error.localizedDescription }
    }

    func pick(_ sound: Sound, for event: ClaudioEvent) {
        do {
            try controller.setSound(sound.url, for: event, writeHook: enabled)
            refresh()
        } catch { lastError = error.localizedDescription }
    }

    func importSound(_ url: URL, for event: ClaudioEvent) {
        do {
            try controller.setSound(url, for: event, writeHook: enabled)
            refresh()
        } catch { lastError = error.localizedDescription }
    }

    func preview(for event: ClaudioEvent) {
        let url = controller.library.activeSoundURL(for: event)
            ?? systemSounds.first { $0.name == selected[event] }?.url
        guard let url else { return }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/afplay")
        process.arguments = [url.path]
        try? process.run()
    }
}
