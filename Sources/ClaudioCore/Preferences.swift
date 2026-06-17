import Foundation

/// App-owned memory of the user's selections, backed by UserDefaults.
public struct Preferences {
    private let defaults: UserDefaults
    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var enabled: Bool {
        get { defaults.bool(forKey: "claudio.enabled") }
        nonmutating set { defaults.set(newValue, forKey: "claudio.enabled") }
    }

    public func selectedSoundName(for event: ClaudioEvent) -> String? {
        defaults.string(forKey: "claudio.sound.\(event.rawValue)")
    }

    public func setSelectedSoundName(_ name: String?, for event: ClaudioEvent) {
        defaults.set(name, forKey: "claudio.sound.\(event.rawValue)")
    }
}
