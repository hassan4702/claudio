import Foundation

/// Pure transforms over a parsed `settings.json` root object (`[String: Any]`).
/// Every function returns a NEW root and never drops keys it doesn't recognize.
/// "Our" hooks are identified by their command containing `marker`.
public enum SettingsTransformer {

    /// Returns a copy of `root` with our hook for `event` installed. Idempotent:
    /// any pre-existing Claudio hook for this event is replaced; foreign hooks kept.
    public static func enable(
        root: [String: Any],
        event: ClaudioEvent,
        command: String,
        marker: String
    ) -> [String: Any] {
        var root = root
        var hooks = (root["hooks"] as? [String: Any]) ?? [:]
        var groups = (hooks[event.settingsKey] as? [Any]) ?? []
        groups = groups.filter { !elementBelongsToUs($0, marker: marker) }
        groups.append(HookBuilder.hookGroup(command: command))
        hooks[event.settingsKey] = groups
        root["hooks"] = hooks
        return root
    }

    /// Returns a copy of `root` with our hook(s) for `event` removed. Empty
    /// containers are pruned so the file returns to its pre-Claudio shape.
    public static func disable(
        root: [String: Any],
        event: ClaudioEvent,
        marker: String
    ) -> [String: Any] {
        var root = root
        guard var hooks = root["hooks"] as? [String: Any] else { return root }
        guard var groups = hooks[event.settingsKey] as? [Any] else { return root }
        groups = groups.filter { !elementBelongsToUs($0, marker: marker) }
        if groups.isEmpty {
            hooks.removeValue(forKey: event.settingsKey)
        } else {
            hooks[event.settingsKey] = groups
        }
        if hooks.isEmpty {
            root.removeValue(forKey: "hooks")
        } else {
            root["hooks"] = hooks
        }
        return root
    }

    /// True if a Claudio-owned hook for `event` is present.
    public static func isEnabled(
        root: [String: Any],
        event: ClaudioEvent,
        marker: String
    ) -> Bool {
        guard let hooks = root["hooks"] as? [String: Any],
              let groups = hooks[event.settingsKey] as? [Any] else { return false }
        return groups.contains { elementBelongsToUs($0, marker: marker) }
    }

    /// A hook-group array element belongs to us if any of its commands contain `marker`.
    /// Non-dictionary elements are treated as foreign (never ours), so they are preserved.
    private static func elementBelongsToUs(_ element: Any, marker: String) -> Bool {
        guard let group = element as? [String: Any],
              let hooks = group["hooks"] as? [Any] else { return false }
        return hooks.contains { hook in
            guard let dict = hook as? [String: Any],
                  let command = dict["command"] as? String else { return false }
            return command.contains(marker)
        }
    }
}
