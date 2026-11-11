import AppKit
import SwiftUI
import TimeFloatCore

/// A native drag target: borderless panels do not reliably expose system resize edges.
struct ResizeHandle: NSViewRepresentable {
    func makeNSView(context: Context) -> ResizeHandleView { ResizeHandleView() }
    func updateNSView(_ view: ResizeHandleView, context: Context) {}
}

final class ResizeHandleView: NSView {
    override var mouseDownCanMoveWindow: Bool { false }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .crosshair)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.secondaryLabelColor.withAlphaComponent(0.65).setStroke()
        let path = NSBezierPath()
        path.lineWidth = 2
        path.lineCapStyle = .round
        for offset in [CGFloat(0), 6, 12] {
            path.move(to: NSPoint(x: 7 + offset, y: 5))
            path.line(to: NSPoint(x: 21, y: 19 - offset))
        }
        path.stroke()
    }

    override func mouseDown(with event: NSEvent) {
        guard let window else { return }
        let initialFrame = window.frame
        let initialMouse = NSEvent.mouseLocation
        let ratio = WindowGeometry.aspectRatio
        while let next = window.nextEvent(matching: [.leftMouseDragged, .leftMouseUp]) {
            if next.type == .leftMouseUp { break }
            let mouse = NSEvent.mouseLocation
            let dx = mouse.x - initialMouse.x
            let dy = mouse.y - initialMouse.y
            // Project diagonal motion onto the fixed aspect ratio, anchoring the top left.
            let deltaWidth = (dx - dy / ratio) / (1 + 1 / (ratio * ratio))
            var size = WindowGeometry.size(width: initialFrame.width + deltaWidth)
            if let screen = window.screen {
                let availableWidth = max(1, screen.visibleFrame.maxX - initialFrame.minX)
                let availableHeight = max(1, initialFrame.maxY - screen.visibleFrame.minY)
                let limit = min(1, min(availableWidth / size.width, availableHeight / size.height))
                size.width *= limit
                size.height *= limit
            }
            window.setFrame(NSRect(x: initialFrame.minX, y: initialFrame.maxY - size.height,
                                   width: size.width, height: size.height), display: true)
        }
    }
}
