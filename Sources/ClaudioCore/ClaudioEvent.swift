import Foundation

public enum ClaudioEvent: String, CaseIterable, Sendable {
    case done
    case needsInput

    /// The Claude Code hook event key this maps to.
    public var settingsKey: String {
        switch self {
        case .done: return "Stop"
        case .needsInput: return "Notification"
        }
    }

    /// Stable file-name stem for the active sound copy in Application Support.
    public var fileStem: String {
        switch self {
        case .done: return "done"
        case .needsInput: return "needs-input"
        }
    }

    /// Human-facing label for the UI.
    public var label: String {
        switch self {
        case .done: return "When Claude finishes"
        case .needsInput: return "When Claude needs you"
        }
    }
}
