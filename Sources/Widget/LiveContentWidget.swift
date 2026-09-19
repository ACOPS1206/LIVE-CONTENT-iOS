import ActivityKit
import SwiftUI
import UIKit
import WidgetKit

struct LiveContentWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveContentAttributes.self) { context in
            LockScreenView(state: context.state)
                .activityBackgroundTint(.black.opacity(0.88))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    LiveThumbnail(state: context.state, size: 44)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.title)
                        .font(.headline)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.state.message)
                            .font(.subheadline)
                            .lineLimit(2)
                        Spacer()
                        Text(context.state.updatedAt, style: .time)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            } compactLeading: {
                Image(systemName: context.state.symbol)
                    .foregroundStyle(Color(widgetHex: context.state.accentHex))
            } compactTrailing: {
                Text(context.state.title)
                    .font(.caption2.weight(.semibold))
                    .lineLimit(1)
                    .frame(maxWidth: 52)
            } minimal: {
                Image(systemName: context.state.symbol)
                    .foregroundStyle(Color(widgetHex: context.state.accentHex))
            }
            .keylineTint(Color(widgetHex: context.state.accentHex))
        }
    }
}

private struct LockScreenView: View {
    let state: LiveContentAttributes.ContentState

    var body: some View {
        HStack(spacing: 14) {
            LiveThumbnail(state: state, size: 52)
            VStack(alignment: .leading, spacing: 4) {
                Text(state.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(state.message)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))
                    .lineLimit(2)
            }
            Spacer(minLength: 8)
            Text(state.updatedAt, style: .time)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(16)
    }
}

private struct LiveThumbnail: View {
    let state: LiveContentAttributes.ContentState
    let size: CGFloat

    var body: some View {
        if let data = state.imageData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.24, style: .continuous))
        } else {
            Image(systemName: state.symbol)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(Color(widgetHex: state.accentHex))
                .frame(width: size, height: size)
                .background(Color(widgetHex: state.accentHex).opacity(0.18), in: RoundedRectangle(cornerRadius: size * 0.24, style: .continuous))
        }
    }
}

private extension Color {
    init(widgetHex: String) {
        let cleaned = widgetHex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let value = UInt64(cleaned, radix: 16) ?? 0x8B5CF6
        self.init(
            .sRGB,
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255,
            opacity: 1
        )
    }
}

