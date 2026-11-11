import SwiftUI

struct GlassBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .underWindowBackground
        view.appearance = NSAppearance(named: .aqua)
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }
    func updateNSView(_ view: NSVisualEffectView, context: Context) {}
}

struct ClockView: View {
    @ObservedObject var model: ClockModel
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            TimelineView(.periodic(from: .now, by: 1)) { timeline in
                VStack(spacing: width * 0.025) {
                    Text(model.formatter.timeString(timeline.date))
                        .font(.system(size: width * 0.17, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Color.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text(model.formatter.dateString(timeline.date))
                        .font(.system(size: width * 0.05, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.48))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .padding(.horizontal, width * 0.07)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background {
                GlassBackground()
                    // A thin white tint preserves the blurred colors behind the window.
                    .overlay(Color.white.opacity(model.settings.opacity * 0.22))
            }
            .clipShape(RoundedRectangle(cornerRadius: width * 0.105, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: width * 0.105, style: .continuous)
                .strokeBorder(Color.black.opacity(0.22), lineWidth: 1))
            .overlay { WindowInteractionSurface() }
        }
        .environment(\.colorScheme, .light)
        .accessibilityLabel("TimeFloat 时钟")
    }
}
