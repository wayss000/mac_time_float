import SwiftUI
import TimeFloatCore

final class ClockModel: ObservableObject {
    @Published var settings: Settings {
        didSet { store.save(settings); formatter = ClockFormatter(settings: settings) }
    }
    private let store = SettingsStore()
    private(set) var formatter: ClockFormatter
    init() {
        let saved = SettingsStore().load()
        settings = saved
        formatter = ClockFormatter(settings: saved)
    }
}
