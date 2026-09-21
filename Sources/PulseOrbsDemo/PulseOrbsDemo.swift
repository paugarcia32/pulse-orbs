import AppKit
import SwiftUI
import ThinkingOrbs

@main
struct PulseOrbsDemoApp: App {
    var body: some Scene {
        WindowGroup("Pulse Orbs") {
            OrbGallery()
        }
        .defaultSize(width: 820, height: 650)
        .windowResizability(.contentMinSize)
    }
}

private struct OrbGallery: View {
    @State private var appearance = DemoAppearance.system
    @State private var isPaused = false
    @State private var speed = 1.0

    private let columns = [
        GridItem(.adaptive(minimum: 210, maximum: 260), spacing: 16),
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(OrbDesign.allCases) { design in
                        OrbCard(design: design, speed: speed, isPaused: isPaused)
                    }
                }
                .padding(20)
            }
        }
        .frame(minWidth: 680, minHeight: 500)
        .preferredColorScheme(appearance.colorScheme)
        .toolbar { controls }
        .onAppear { NSApp.activate(ignoringOtherApps: true) }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Pulse Orbs")
                .font(.title.bold())
            Text("Native activity glyphs at their regular and inline sizes")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    @ToolbarContentBuilder
    private var controls: some ToolbarContent {
        ToolbarItemGroup {
            Picker("Appearance", selection: $appearance) {
                ForEach(DemoAppearance.allCases) { appearance in
                    Text(appearance.title).tag(appearance)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 180)

            HStack(spacing: 8) {
                Image(systemName: "tortoise")
                    .accessibilityHidden(true)
                Slider(value: $speed, in: 0.25...2, step: 0.25)
                    .frame(width: 110)
                    .accessibilityLabel("Animation speed")
                Text(speed, format: .number.precision(.fractionLength(2)))
                    .monospacedDigit()
                    .frame(width: 34, alignment: .trailing)
                    .accessibilityHidden(true)
                Image(systemName: "hare")
                    .accessibilityHidden(true)
            }

            Button {
                isPaused.toggle()
            } label: {
                Label(isPaused ? "Resume" : "Pause", systemImage: isPaused ? "play.fill" : "pause.fill")
            }
            .keyboardShortcut(.space, modifiers: [])
            .help(isPaused ? "Resume animations (Space)" : "Pause animations (Space)")
        }
    }
}

private struct OrbCard: View {
    let design: OrbDesign
    let speed: Double
    let isPaused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 18) {
                ThinkingOrb(design, speed: speed, isPaused: isPaused)
                    .frame(maxWidth: .infinity)

                VStack(spacing: 8) {
                    ThinkingOrb(design, size: .small, speed: speed, isPaused: isPaused)
                    Text("20 pt")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .frame(width: 46)
            }
            .frame(height: 76)

            VStack(alignment: .leading, spacing: 3) {
                Text(design.title)
                    .font(.headline)
                Text(design.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 142, alignment: .topLeading)
        .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
        }
        .accessibilityElement(children: .contain)
    }
}

private enum DemoAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: Self { self }

    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
