/// Pure construction of Claude Code hook JSON fragments. No I/O.
public enum HookBuilder {
    /// The shell command that plays a sound file via macOS `afplay`.
    public static func command(forSoundAt path: String) -> String {
        "afplay \"\(path)\""
    }

    /// A single hook-group object as it appears inside `hooks.<Event>`:
    /// `{ "hooks": [ { "type": "command", "command": "...", "async": true } ] }`
    public static func hookGroup(command: String) -> [String: Any] {
        [
            "hooks": [
                [
                    "type": "command",
                    "command": command,
                    "async": true,
                ] as [String: Any]
            ]
        ]
    }
}
