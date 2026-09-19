import ActivityKit
import PhotosUI
import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var manager = LiveActivityManager()
    @State private var title = "오늘의 한 줄"
    @State private var message = "Dynamic Island에 표시할 내용을 입력하세요."
    @State private var symbol = "sparkles"
    @State private var accentHex = "#8B5CF6"
    @State private var photoItem: PhotosPickerItem?
    @State private var imageData: Data?

    private let symbols = ["sparkles", "bolt.fill", "heart.fill", "star.fill", "bell.fill", "checkmark.circle.fill"]
    private let colors = ["#8B5CF6", "#0A84FF", "#30D158", "#FF9F0A", "#FF375F", "#FFFFFF"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    previewSection
                    contentSection
                    appearanceSection
                    availabilityNotice
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, manager.isActive ? 112 : 96)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(background)
            .navigationTitle("Live Content")
            .navigationBarTitleDisplayMode(.large)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bottomControls
            }
            .alert("실시간 현황 오류", isPresented: errorPresented) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(manager.errorMessage ?? "알 수 없는 오류")
            }
        }
        .tint(accentColor)
        .onChange(of: photoItem) { _, newItem in
            Task {
                guard let data = try? await newItem?.loadTransferable(type: Data.self) else {
                    imageData = nil
                    return
                }
                imageData = ImageThumbnail.make(from: data)
            }
        }
    }

    private var background: some View {
        ZStack {
            Color(uiColor: .systemBackground)
            RadialGradient(
                colors: [accentColor.opacity(colorScheme == .dark ? 0.22 : 0.14), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 420
            )
        }
        .ignoresSafeArea()
    }

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("미리보기", systemImage: "rectangle.on.rectangle")
            HStack(spacing: 14) {
                thumbnail(size: 56)
                VStack(alignment: .leading, spacing: 5) {
                    Text(cleanTitle.isEmpty ? "제목" : cleanTitle)
                        .font(.headline)
                        .lineLimit(1)
                    Text(cleanMessage.isEmpty ? "메시지" : cleanMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer(minLength: 8)
                Image(systemName: symbol)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(accentColor)
                    .accessibilityHidden(true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 96)
            .adaptiveGlass(in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("실시간 현황 미리보기, \(cleanTitle), \(cleanMessage)")
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("내용", systemImage: "text.alignleft")
            VStack(spacing: 12) {
                TextField("제목", text: $title)
                    .textFieldStyle(.plain)
                    .submitLabel(.next)
                    .padding(.horizontal, 15)
                    .frame(minHeight: 50)
                    .inputSurface()
                    .accessibilityLabel("실시간 현황 제목")
                TextField("메시지", text: $message, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(2...4)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 13)
                    .frame(minHeight: 72, alignment: .topLeading)
                    .inputSurface()
                    .accessibilityLabel("실시간 현황 메시지")
                PhotosPicker(selection: $photoItem, matching: .images) {
                    HStack {
                        Label(imageData == nil ? "사진 선택" : "사진 변경", systemImage: "photo")
                        Spacer()
                        if imageData != nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(accentColor)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .contentShape(Rectangle())
                }
                .modifier(AdaptiveGlassButtonStyle())
                .accessibilityHint("사진은 실시간 현황에 맞게 작은 크기로 자동 압축됩니다")
            }
            .padding(16)
            .adaptiveGlass(in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("모양", systemImage: "paintpalette")
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("기호")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    symbolPicker
                }
                Divider()
                VStack(alignment: .leading, spacing: 10) {
                    Text("강조 색상")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    colorPicker
                }
            }
            .padding(16)
            .adaptiveGlass(in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
    }

    @ViewBuilder
    private var symbolPicker: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: 8) { symbolButtons }
        } else {
            symbolButtons
        }
    }

    private var symbolButtons: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(symbols, id: \.self) { item in
                    Button {
                        symbol = item
                    } label: {
                        Image(systemName: item)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(symbol == item ? accentColor : .primary)
                            .frame(width: 44, height: 44)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .adaptiveGlass(in: Circle(), interactive: true)
                    .overlay {
                        if symbol == item { Circle().stroke(accentColor, lineWidth: 2) }
                    }
                    .accessibilityLabel("\(item) 기호")
                    .accessibilityAddTraits(symbol == item ? .isSelected : [])
                }
            }
            .padding(3)
        }
        .scrollIndicators(.hidden)
    }

    private var colorPicker: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(colors, id: \.self) { hex in
                    Button {
                        accentHex = hex
                    } label: {
                        Circle()
                            .fill(Color(hex: hex))
                            .frame(width: 28, height: 28)
                            .overlay {
                                if hex == "#FFFFFF" { Circle().stroke(.secondary.opacity(0.4), lineWidth: 1) }
                            }
                            .frame(width: 44, height: 44)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .overlay {
                        if accentHex == hex { Circle().stroke(.primary, lineWidth: 2) }
                    }
                    .accessibilityLabel("강조 색상 \(colorName(for: hex))")
                    .accessibilityAddTraits(accentHex == hex ? .isSelected : [])
                }
            }
            .padding(3)
        }
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private var availabilityNotice: some View {
        if !manager.activitiesEnabled {
            Label {
                Text("설정에서 이 앱의 실시간 현황을 허용해 주세요.")
            } icon: {
                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.yellow)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .adaptiveGlass(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    @ViewBuilder
    private var bottomControls: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: 12) { controlButtons }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
        } else {
            controlButtons
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
        }
    }

    private var controlButtons: some View {
        HStack(spacing: 12) {
            Button {
                Task { await manager.startOrUpdate(state: currentState) }
            } label: {
                Label(
                    manager.isActive ? "업데이트" : "실시간 현황 시작",
                    systemImage: manager.isActive ? "arrow.triangle.2.circlepath" : "play.fill"
                )
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, minHeight: 50)
            }
            .modifier(AdaptiveProminentButtonStyle())
            .disabled(cleanTitle.isEmpty && cleanMessage.isEmpty)
            .accessibilityHint(manager.isActive ? "현재 실시간 현황의 내용을 변경합니다" : "잠금 화면과 Dynamic Island에 표시합니다")

            if manager.isActive {
                Button(role: .destructive) {
                    Task { await manager.end(state: currentState) }
                } label: {
                    Image(systemName: "stop.fill").frame(width: 50, height: 50)
                }
                .modifier(AdaptiveGlassButtonStyle())
                .accessibilityLabel("실시간 현황 종료")
            }
        }
    }

    private func sectionHeader(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.headline)
            .padding(.horizontal, 4)
    }

    @ViewBuilder
    private func thumbnail(size: CGFloat) -> some View {
        if let imageData, let image = UIImage(data: imageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.24, style: .continuous))
        } else {
            Image(systemName: symbol)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(accentColor)
                .frame(width: size, height: size)
                .background(accentColor.opacity(0.16), in: RoundedRectangle(cornerRadius: size * 0.24, style: .continuous))
        }
    }

    private var accentColor: Color { Color(hex: accentHex) }
    private var cleanTitle: String { String(title.trimmingCharacters(in: .whitespacesAndNewlines).prefix(40)) }
    private var cleanMessage: String { String(message.trimmingCharacters(in: .whitespacesAndNewlines).prefix(120)) }

    private var currentState: LiveContentAttributes.ContentState {
        .init(title: cleanTitle, message: cleanMessage, symbol: symbol, accentHex: accentHex, imageData: imageData, updatedAt: .now)
    }

    private var errorPresented: Binding<Bool> {
        Binding(
            get: { manager.errorMessage != nil },
            set: { if !$0 { manager.errorMessage = nil } }
        )
    }

    private func colorName(for hex: String) -> String {
        switch hex {
        case "#8B5CF6": "보라색"
        case "#0A84FF": "파란색"
        case "#30D158": "초록색"
        case "#FF9F0A": "주황색"
        case "#FF375F": "분홍색"
        default: "흰색"
        }
    }
}

private struct AdaptiveProminentButtonStyle: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) { content.buttonStyle(.glassProminent) }
        else { content.buttonStyle(.borderedProminent) }
    }
}

private struct AdaptiveGlassButtonStyle: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) { content.buttonStyle(.glass) }
        else { content.buttonStyle(.bordered) }
    }
}

private extension View {
    @ViewBuilder
    func adaptiveGlass<S: Shape>(in shape: S, interactive: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            if interactive { glassEffect(.regular.interactive(), in: shape) }
            else { glassEffect(.regular, in: shape) }
        } else {
            background(.regularMaterial, in: shape)
        }
    }

    func inputSurface() -> some View {
        background(Color(uiColor: .secondarySystemBackground).opacity(0.82), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(uiColor: .separator).opacity(0.22), lineWidth: 0.5)
            }
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
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
