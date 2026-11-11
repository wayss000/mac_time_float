import AppKit
import SwiftUI
import TimeFloatCore

/// Own pointer interaction so borderless windows support both dragging and resizing.
struct WindowInteractionSurface: NSViewRepresentable {
    func makeNSView(context: Context) -> WindowInteractionView { WindowInteractionView() }
    func updateNSView(_ view: WindowInteractionView, context: Context) {}
}

final class WindowInteractionView: NSView {
    override var mouseDownCanMoveWindow: Bool { false }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    private func edges(at point: NSPoint) -> (left: Bool, right: Bool, bottom: Bool, top: Bool) {
        let corner = CGFloat(30)
        let nearX = point.x < corner || point.x > bounds.width - corner
        let nearY = point.y < corner || point.y > bounds.height - corner
        let margin: CGFloat = nearX && nearY ? corner : 10
        return (point.x < margin, point.x > bounds.width - margin,
                point.y < margin, point.y > bounds.height - margin)
    }

    override func resetCursorRects() {
        let w = bounds.width, h = bounds.height
        addCursorRect(NSRect(x: 0, y: 30, width: 10, height: max(0, h - 60)), cursor: .resizeLeftRight)
        addCursorRect(NSRect(x: w - 10, y: 30, width: 10, height: max(0, h - 60)), cursor: .resizeLeftRight)
        addCursorRect(NSRect(x: 30, y: 0, width: max(0, w - 60), height: 10), cursor: .resizeUpDown)
        addCursorRect(NSRect(x: 30, y: h - 10, width: max(0, w - 60), height: 10), cursor: .resizeUpDown)
        for x in [CGFloat(0), w - 30] {
            for y in [CGFloat(0), h - 30] {
                addCursorRect(NSRect(x: x, y: y, width: 30, height: 30), cursor: .crosshair)
            }
        }
    }

    override func menu(for event: NSEvent) -> NSMenu? {
        (window as? ClockPanel)?.interactionMenu
    }

    override func mouseDown(with event: NSEvent) {
        guard let window else { return }
        let edge = edges(at: convert(event.locationInWindow, from: nil))
        guard edge.left || edge.right || edge.bottom || edge.top else {
            window.performDrag(with: event)
            (window as? ClockPanel)?.fitToScreen()
            return
        }
        let initialFrame = window.frame
        let initialMouse = NSEvent.mouseLocation
        let ratio = WindowGeometry.aspectRatio
        while let next = window.nextEvent(matching: [.leftMouseDragged, .leftMouseUp]) {
            if next.type == .leftMouseUp { break }
            let mouse = NSEvent.mouseLocation
            let dx = (mouse.x - initialMouse.x) * (edge.left ? -1 : 1)
            let dy = (mouse.y - initialMouse.y) * (edge.bottom ? -1 : 1)
            let horizontal = edge.left || edge.right
            let vertical = edge.bottom || edge.top
            let delta: CGFloat
            if horizontal && vertical {
                delta = (dx + dy / ratio) / (1 + 1 / (ratio * ratio))
            } else {
                delta = horizontal ? dx : dy * ratio
            }
            let size = WindowGeometry.size(width: initialFrame.width + delta)
            let x = edge.left ? initialFrame.maxX - size.width : initialFrame.minX
            let y = edge.bottom ? initialFrame.maxY - size.height : initialFrame.minY
            window.setFrame(NSRect(origin: NSPoint(x: x, y: y), size: size), display: true)
        }
        (window as? ClockPanel)?.fitToScreen()
    }
}
