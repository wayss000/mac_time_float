import AppKit
import SwiftUI
import TimeFloatCore

final class ClockPanel: NSPanel, NSWindowDelegate {
    override var canBecomeKey: Bool { true }
    init(model: ClockModel) {
        super.init(contentRect: CGRect(origin: .zero, size: WindowGeometry.size(width: 640)),
                   styleMask: [.borderless, .resizable, .nonactivatingPanel], backing: .buffered, defer: false)
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        isMovableByWindowBackground = true
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        contentMinSize = WindowGeometry.size(width: 300)
        contentMaxSize = WindowGeometry.size(width: 1200)
        contentAspectRatio = WindowGeometry.size(width: 640)
        contentView = NSHostingView(rootView: ClockView(model: model))
        center()
        if let saved = UserDefaults.standard.string(forKey: "TimeFloat.frame") {
            let frame = NSRectFromString(saved)
            if frame.width.isFinite, frame.height.isFinite, frame.origin.x.isFinite, frame.origin.y.isFinite {
                setFrame(frame, display: false)
            }
        }
        fitToScreen()
        delegate = self
        apply(model.settings)
    }
    func apply(_ settings: Settings) { level = settings.alwaysOnTop ? .floating : .normal }
    func fitToScreen() {
        let screens = NSScreen.screens
        let screen = screens.first(where: { $0.visibleFrame.intersects(frame) }) ?? NSScreen.main
        if let screen { setFrame(WindowGeometry.fitted(frame, to: screen.visibleFrame), display: true) }
    }
    func resetPosition() {
        setContentSize(WindowGeometry.size(width: 640))
        center()
        saveFrame()
    }
    private func saveFrame() { UserDefaults.standard.set(NSStringFromRect(frame), forKey: "TimeFloat.frame") }
    func windowDidMove(_ notification: Notification) { saveFrame() }
    func windowDidResize(_ notification: Notification) { saveFrame() }
}
