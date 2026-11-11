import AppKit
import Combine

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let model = ClockModel()
    private var panel: ClockPanel!
    private var statusItem: NSStatusItem!
    private var subscription: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        panel = ClockPanel(model: model)
        panel.orderFrontRegardless()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "TimeFloat")
        rebuildMenu()
        subscription = model.$settings.sink { [weak self] settings in
            self?.panel.apply(settings)
            DispatchQueue.main.async { self?.rebuildMenu() }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(screensChanged),
            name: NSApplication.didChangeScreenParametersNotification, object: nil)
    }
    private func rebuildMenu() {
        let menu = NSMenu()
        func add(_ title: String, _ action: Selector, checked: Bool? = nil, tag: Int = 0) {
            let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
            item.target = self
            item.tag = tag
            if let checked { item.state = checked ? .on : .off }
            menu.addItem(item)
        }
        add(panel.isVisible ? "隐藏时钟" : "显示时钟", #selector(toggleVisible))
        menu.addItem(.separator())
        add("24 小时制", #selector(toggle24), checked: model.settings.use24Hours)
        add("显示秒", #selector(toggleSeconds), checked: model.settings.showSeconds)
        add("窗口置顶", #selector(toggleTop), checked: model.settings.alwaysOnTop)
        let opacity = NSMenuItem(title: "背景浓度", action: nil, keyEquivalent: "")
        let submenu = NSMenu()
        for value in [25, 50, 80, 100] {
            let item = NSMenuItem(title: "\(value)%", action: #selector(changeOpacity(_:)), keyEquivalent: "")
            item.target = self
            item.tag = value
            item.state = abs(model.settings.opacity - Double(value) / 100) < 0.01 ? .on : .off
            submenu.addItem(item)
        }
        opacity.submenu = submenu
        menu.addItem(opacity)
        add("恢复默认位置和大小", #selector(resetPosition))
        menu.addItem(.separator())
        add("退出 TimeFloat", #selector(quit))
        statusItem.menu = menu
    }
    @objc private func toggleVisible() {
        if panel.isVisible { panel.orderOut(nil) } else { panel.fitToScreen(); panel.orderFrontRegardless() }
        rebuildMenu()
    }
    @objc private func toggle24() { model.settings.use24Hours.toggle() }
    @objc private func toggleSeconds() { model.settings.showSeconds.toggle() }
    @objc private func toggleTop() { model.settings.alwaysOnTop.toggle() }
    @objc private func changeOpacity(_ sender: NSMenuItem) { model.settings.opacity = Double(sender.tag) / 100 }
    @objc private func resetPosition() { panel.resetPosition(); panel.orderFrontRegardless(); rebuildMenu() }
    @objc private func screensChanged() { panel.fitToScreen() }
    @objc private func quit() { NSApp.terminate(nil) }
}
