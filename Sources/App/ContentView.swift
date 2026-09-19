import ActivityKit
import PhotosUI
import SwiftUI
import UIKit

struct ContentView: View {
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
                VStack(spacing: 22) {
                    preview
                    editor
                    controls
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Live Content")
            .alert("실시간 현황 오류", isPresented: errorPresented) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(manager.errorMessage ?? "알 수 없는 오류")
            }
        }
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

    private var preview: some View {
        HStack(spacing: 14) {
            thumbnail(size: 54)

            VStack(alignment: .leading, spacing: 4) {
                Text(cleanTitle.isEmpty ? "제목" : cleanTitle)
                    .font(.headline)
                    .lineLimit(1)
                Text(cleanMessage.isEmpty ? "메시지" : cleanMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
            Image(systemName: symbol)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color(hex: accentHex))
        }
        .padding(18)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var editor: some View {
        VStack(spacing: 14) {
            TextField("제목", text: $title)
                .textFieldStyle(.roundedBorder)
            TextField("메시지", text: $message, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)

            PhotosPicker(selection: $photoItem, matching: .images) {
                Label(imageData == nil ? "사진 선택" : "사진 변경", systemImage: "photo")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            HStack {
                ForEach(symbols, id: \.self) { item in
                    Button {
                        symbol = item
                    } label: {
                        Image(systemName: item)
                            .frame(width: 28, height: 28)
                            .background(symbol == item ? Color.primary.opacity(0.12) : .clear, in: Circle())
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                ForEach(colors, id: \.self) { hex in
                    Button {
                        accentHex = hex
                    } label: {
                        Circle()
                            .fill(Color(hex: hex))
                            .frame(width: 30, height: 30)
                            .overlay {
                                if accentHex == hex {
                                    Circle().stroke(.primary, lineWidth: 2).padding(-3)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(18)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var controls: some View {
        VStack(spacing: 12) {
            Button {
                Task { await manager.startOrUpdate(state: currentState) }
            } label: {
                Label(manager.isActive ? "실시간 현황 업데이트" : "실시간 현황 시작", systemImage: manager.isActive ? "arrow.triangle.2.circlepath" : "play.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: accentHex))
            .disabled(cleanTitle.isEmpty && cleanMessage.isEmpty)

            if manager.isActive {
                Button(role: .destructive) {
                    Task { await manager.end(state: currentState) }
                } label: {
                    Label("실시간 현황 종료", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            if !manager.activitiesEnabled {
                Text("이 기기에서 실시간 현황이 꺼져 있습니다.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
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
                .foregroundStyle(Color(hex: accentHex))
                .frame(width: size, height: size)
                .background(Color(hex: accentHex).opacity(0.16), in: RoundedRectangle(cornerRadius: size * 0.24, style: .continuous))
        }
    }

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

