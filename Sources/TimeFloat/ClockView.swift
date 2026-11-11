import SwiftUI

struct GlassBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow
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
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text(model.formatter.dateString(timeline.date))
                        .font(.system(size: width * 0.05, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .padding(.horizontal, width * 0.07)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background {
                GlassBackground()
                    .overlay(Color.white.opacity(model.settings.opacity * 0.45))
                    .overlay(LinearGradient(colors: [.pink.opacity(0.09), .blue.opacity(0.08)], startPoint: .bottomLeading, endPoint: .topTrailing))
            }
            .clipShape(RoundedRectangle(cornerRadius: width * 0.105, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: width * 0.105, style: .continuous)
                .strokeBorder(.primary.opacity(0.2), lineWidth: 1))
            .overlay(alignment: .bottomTrailing) {
                ResizeHandle()
                    .frame(width: 26, height: 26)
                    .padding(12)
                    .help("拖动调整时钟大小")
            }
        }
        .accessibilityLabel("TimeFloat 时钟")
    }
}
