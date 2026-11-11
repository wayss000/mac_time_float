import Foundation

public struct Settings: Codable, Equatable {
    public var use24Hours = true
    public var showSeconds = true
    public var alwaysOnTop = true
    public var opacity = 0.8
    public init() {}
}

public struct SettingsStore {
    private let defaults: UserDefaults
    private let key = "TimeFloat.settings"
    public init(defaults: UserDefaults = .standard) { self.defaults = defaults }
    public func load() -> Settings {
        guard let data = defaults.data(forKey: key),
              var settings = try? JSONDecoder().decode(Settings.self, from: data) else { return Settings() }
        settings.opacity = settings.opacity.isFinite ? min(1, max(0.25, settings.opacity)) : 0.8
        return settings
    }
    public func save(_ settings: Settings) {
        if let data = try? JSONEncoder().encode(settings) { defaults.set(data, forKey: key) }
    }
}
