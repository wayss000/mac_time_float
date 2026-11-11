import XCTest
import CoreGraphics
@testable import TimeFloatCore

final class CoreTests: XCTestCase {
    func testTimeFormats() {
        let date = Date(timeIntervalSince1970: 15 * 3600 + 4 * 60 + 5)
        var settings = Settings()
        let locale = Locale(identifier: "en_US_POSIX")
        let zone = TimeZone(secondsFromGMT: 0)!
        XCTAssertEqual(ClockFormatter(settings: settings, locale: locale, timeZone: zone).timeString(date), "15:04:05")
        settings.showSeconds = false
        XCTAssertEqual(ClockFormatter(settings: settings, locale: locale, timeZone: zone).timeString(date), "15:04")
        settings.use24Hours = false
        XCTAssertEqual(ClockFormatter(settings: settings, locale: locale, timeZone: zone).timeString(date), "3:04 PM")
    }
    func testSettingsPersistAndRecoverFromCorruptData() {
        let name = "TimeFloatTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let store = SettingsStore(defaults: defaults)
        XCTAssertEqual(store.load(), Settings())
        var settings = Settings()
        settings.showSeconds = false
        settings.opacity = 0.5
        store.save(settings)
        XCTAssertEqual(store.load(), settings)
        settings.opacity = 2
        store.save(settings)
        XCTAssertEqual(store.load().opacity, 1)
        defaults.set(Data("broken".utf8), forKey: "TimeFloat.settings")
        XCTAssertEqual(store.load(), Settings())
    }
    func testOffscreenWindowReturnsToVisibleScreen() {
        let screen = CGRect(x: -1440, y: 0, width: 1440, height: 900)
        let frame = WindowGeometry.fitted(CGRect(x: 3000, y: -500, width: 640, height: 300), to: screen)
        XCTAssertTrue(screen.contains(frame))
        XCTAssertEqual(frame.width / frame.height, WindowGeometry.aspectRatio, accuracy: 0.001)
    }
    func testResizeBoundsAndSmallScreen() {
        XCTAssertEqual(WindowGeometry.size(width: 10).width, 300)
        XCTAssertEqual(WindowGeometry.size(width: 9000).width, 1200)
        let screen = CGRect(x: 0, y: 0, width: 200, height: 100)
        XCTAssertTrue(screen.contains(WindowGeometry.fitted(CGRect(x: 0, y: 0, width: 640, height: 333), to: screen)))
    }
}
