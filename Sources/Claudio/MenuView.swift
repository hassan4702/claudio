import SwiftUI
import AppKit
import UniformTypeIdentifiers
import ClaudioCore

struct MenuView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Claudio").font(.headline)

            if !model.claudeInstalled {
                Text("Couldn't find Claude Code.\nIs it installed?")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                Toggle("Enable Claude sounds", isOn: Binding(
                    get: { model.enabled },
                    set: { model.toggle($0) }))
                Divider()
                ForEach(ClaudioEvent.allCases, id: \.self) { event in
                    EventRow(model: model, event: event)
                }
                if model.hasBackup {
                    Divider()
                    Button("Restore original settings") { model.restore() }
                        .font(.caption)
                }
            }

            if let error = model.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Divider()
            Button("Quit Claudio") { NSApplication.shared.terminate(nil) }
        }
        .padding(14)
        .frame(width: 300)
    }
}

private struct EventRow: View {
    @ObservedObject var model: AppModel
    let event: ClaudioEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.label).font(.subheadline).bold()
            HStack {
                Picker("", selection: Binding(
                    get: { model.selected[event] ?? "" },
                    set: { name in
                        if let sound = model.systemSounds.first(where: { $0.name == name }) {
                            model.pick(sound, for: event)
                        }
                    })) {
                        Text("—").tag("")
                        ForEach(model.systemSounds) { sound in
                            Text(sound.name).tag(sound.name)
                        }
                    }
                    .labelsHidden()

                Button { model.preview(for: event) } label: {
                    Image(systemName: "play.circle")
                }
                .buttonStyle(.plain)

                Button("Import…") { importFile() }
                    .font(.caption)
            }
        }
    }

    private func importFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.audio]
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            model.importSound(url, for: event)
        }
    }
}
