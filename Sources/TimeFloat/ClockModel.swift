import SwiftUI
import TimeFloatCore

final class ClockModel: ObservableObject {
    @Published var settings: ClockSettings {
        didSet { store.save(settings); formatter = ClockFormatter(settings: settings) }
    }
    private let store = SettingsStore()
    @Published private(set) var formatter: ClockFormatter
    func refreshClock() { formatter = ClockFormatter(settings: settings) }
    init() {
        let saved = SettingsStore().load()
        settings = saved
        formatter = ClockFormatter(settings: saved)
    }
}
