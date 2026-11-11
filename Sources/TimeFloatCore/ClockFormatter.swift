import Foundation

public struct ClockFormatter {
    private let time: DateFormatter
    private let date: DateFormatter
    public init(settings: ClockSettings, locale: Locale = Locale(identifier: "en_US_POSIX"), timeZone: TimeZone = .autoupdatingCurrent) {
        time = DateFormatter()
        time.locale = locale
        time.timeZone = timeZone
        time.dateFormat = settings.use24Hours
            ? (settings.showSeconds ? "HH:mm:ss" : "HH:mm")
            : (settings.showSeconds ? "h:mm:ss a" : "h:mm a")
        date = DateFormatter()
        date.locale = locale
        date.timeZone = timeZone
        date.dateFormat = "EEEE, MMMM d"
    }
    public func timeString(_ value: Date) -> String { time.string(from: value) }
    public func dateString(_ value: Date) -> String { date.string(from: value) }
}
