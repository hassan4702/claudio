import XCTest
@testable import ClaudioCore

final class SettingsTransformerTests: XCTestCase {
    let marker = "/Users/me/Library/Application Support/Claudio"

    private func parse(_ s: String) -> [String: Any] {
        let data = s.data(using: .utf8)!
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
    }

    private func canonical(_ root: [String: Any]) -> String {
        let data = try! JSONSerialization.data(withJSONObject: root, options: [.sortedKeys])
        return String(data: data, encoding: .utf8)!
    }

    func testEnableAddsHookAndIsDetected() {
        let root = parse(#"{"model":"opus"}"#)
        let cmd = "afplay \"\(marker)/done.aiff\""
        let out = SettingsTransformer.enable(root: root, event: .done, command: cmd, marker: marker)

        XCTAssertTrue(SettingsTransformer.isEnabled(root: out, event: .done, marker: marker))
        // Unrelated keys preserved.
        XCTAssertEqual(out["model"] as? String, "opus")
    }

    func testEnableIsIdempotent() {
        let cmd = "afplay \"\(marker)/done.aiff\""
        var root = parse("{}")
        root = SettingsTransformer.enable(root: root, event: .done, command: cmd, marker: marker)
        root = SettingsTransformer.enable(root: root, event: .done, command: cmd, marker: marker)
        let hooks = root["hooks"] as? [String: Any]
        let groups = hooks?["Stop"] as? [Any]
        XCTAssertEqual(groups?.count, 1, "enabling twice must not duplicate the hook")
    }

    func testEnablePreservesForeignHooks() {
        let root = parse(#"{"hooks":{"Stop":[{"hooks":[{"type":"command","command":"echo hi"}]}]}}"#)
        let cmd = "afplay \"\(marker)/done.aiff\""
        let out = SettingsTransformer.enable(root: root, event: .done, command: cmd, marker: marker)
        let groups = (out["hooks"] as? [String: Any])?["Stop"] as? [Any]
        XCTAssertEqual(groups?.count, 2, "foreign Stop hook must be kept alongside ours")
    }

    func testDisableRestoresOriginalExactly() {
        let original = parse(#"{"model":"opus","theme":"dark"}"#)
        let cmd = "afplay \"\(marker)/done.aiff\""
        let enabled = SettingsTransformer.enable(root: original, event: .done, command: cmd, marker: marker)
        let disabled = SettingsTransformer.disable(root: enabled, event: .done, marker: marker)
        XCTAssertEqual(canonical(disabled), canonical(original))
    }

    func testDisableKeepsForeignHooks() {
        let root = parse(#"{"hooks":{"Stop":[{"hooks":[{"type":"command","command":"echo hi"}]}]}}"#)
        let cmd = "afplay \"\(marker)/done.aiff\""
        let enabled = SettingsTransformer.enable(root: root, event: .done, command: cmd, marker: marker)
        let disabled = SettingsTransformer.disable(root: enabled, event: .done, marker: marker)
        let groups = (disabled["hooks"] as? [String: Any])?["Stop"] as? [Any]
        XCTAssertEqual(groups?.count, 1)
        XCTAssertFalse(SettingsTransformer.isEnabled(root: disabled, event: .done, marker: marker))
    }
}
