import Foundation
import CoreGraphics

public enum WindowGeometry {
    public static let aspectRatio: CGFloat = 1.92
    public static func size(width: CGFloat) -> CGSize {
        let width = width.isFinite ? min(1200, max(300, width)) : 600
        return CGSize(width: width, height: width / aspectRatio)
    }
    public static func fitted(_ frame: CGRect, to screen: CGRect) -> CGRect {
        var size = self.size(width: frame.width)
        let scale = min(1, min(screen.width / size.width, screen.height / size.height))
        size.width *= scale
        size.height *= scale
        return CGRect(x: min(max(frame.minX, screen.minX), screen.maxX - size.width),
                      y: min(max(frame.minY, screen.minY), screen.maxY - size.height),
                      width: size.width, height: size.height)
    }
}
