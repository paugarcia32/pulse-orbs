//
//  MediaTests.swift
//  ThinkingOrbsTests
//
//  Renders the README's animations frame by frame through the real public
//  views, with the orb clock pinned to each instant, so every GIF is exact and
//  identical run to run. Writes PNG sequences into ORBS_MEDIA_OUT; run it with
//  Scripts/render-media.sh, which turns them into looping GIFs. Skipped
//  otherwise.
//

import Foundation
import ImageIO
import SwiftUI
import Testing
import UniformTypeIdentifiers
@testable import ThinkingOrbs

private let env = ProcessInfo.processInfo.environment

/// GitHub's page colours, so each GIF sits seamlessly on its README theme.
private enum Page: String, CaseIterable {
    case light, dark

    var background: Color {
        switch self {
        case .light: return Color(.sRGB, red: 1, green: 1, blue: 1)
        case .dark: return Color(.sRGB, red: 13 / 255, green: 17 / 255, blue: 23 / 255)
        }
    }

    var surface: Color {
        switch self {
        case .light: return Color(.sRGB, red: 246 / 255, green: 248 / 255, blue: 250 / 255)
        case .dark: return Color(.sRGB, red: 22 / 255, green: 27 / 255, blue: 34 / 255)
        }
    }

    var hairline: Color {
        switch self {
        case .light: return Color(.sRGB, red: 208 / 255, green: 215 / 255, blue: 222 / 255)
        case .dark: return Color(.sRGB, red: 48 / 255, green: 54 / 255, blue: 61 / 255)
        }
    }

    var scheme: ColorScheme { self == .dark ? .dark : .light }
}

@MainActor
struct MediaTests {

    /// 30 ms a frame (GIF delays are in centiseconds), 4.02 s of loop plus
    /// 0.51 s rendered past the end for the seam crossfade.
    static let frameStep = 0.03
    static let frameCount = 151

    @Test(.enabled(if: env["ORBS_MEDIA_OUT"] != nil))
    func rendersReadmeMedia() throws {
        let root = URL(fileURLWithPath: env["ORBS_MEDIA_OUT"]!)

        for page in Page.allCases {
            // one clip per design and size, for the table
            for design in OrbDesign.allCases {
                for size in OrbSize.allCases {
                    let name = "\(design.rawValue)-\(size == .regular ? "regular" : "small")-\(page.rawValue)"
                    try render(name, into: root) {
                        ThinkingOrb(design, size: size)
                            .frame(width: size.points, height: size.points)
                            .background(page.background)
                    }
                }
            }

            // the banner: all nine side by side
            try render("banner-\(page.rawValue)", into: root, scale: 2) {
                HStack(spacing: 0) {
                    ForEach(OrbDesign.allCases) { design in
                        VStack(spacing: 10) {
                            ThinkingOrb(design)
                            Text(design.title)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 92)
                    }
                }
                .padding(.vertical, 22)
                .padding(.horizontal, 18)
                .background(page.background)
            }

            // labels in context: a status pill and inline chips
            try render("labels-\(page.rawValue)", into: root, scale: 2) {
                VStack(alignment: .leading, spacing: 14) {
                    ThinkingOrbLabel("Thinking…", design: .composing, size: .regular, diameter: 48)
                        .font(.system(size: 19))
                        .padding(7)
                        .padding(.trailing, 22)
                        .background(page.surface, in: .capsule)
                        .overlay(Capsule().stroke(page.hairline, lineWidth: 1))
                    HStack(spacing: 8) {
                        chip("Searching the web…", .searching, page)
                        chip("Reading 14 files…", .working, page)
                    }
                    HStack(spacing: 8) {
                        chip("Planning next steps…", .weaving, page)
                        chip("Calling tools…", .connecting, page)
                    }
                }
                .padding(22)
                .background(page.background)
            }
        }
    }

    private func chip(_ title: String, _ design: OrbDesign, _ page: Page) -> some View {
        ThinkingOrbLabel(title, design: design)
            .font(.system(size: 13))
            .padding(.leading, 8)
            .padding(.trailing, 13)
            .frame(height: 34)
            .background(page.surface, in: .capsule)
            .overlay(Capsule().stroke(page.hairline, lineWidth: 1))
    }

    /// Renders `frameCount` frames of `content` with the clock pinned, as
    /// `<name>/0000.png` …, in the page's colour scheme.
    private func render<Content: View>(_ name: String, into root: URL, scale: CGFloat = 3,
                                       @ViewBuilder content: () -> Content) throws {
        let dir = root.appendingPathComponent(name)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let scheme: ColorScheme = name.hasSuffix("-dark") ? .dark : .light
        let view = content()
        for i in 0..<Self.frameCount {
            let renderer = ImageRenderer(content: view
                .environment(\.colorScheme, scheme)
                .environment(\.orbClockOverride, Double(i) * Self.frameStep))
            renderer.scale = scale
            let image = try #require(renderer.cgImage, "\(name) frame \(i)")
            let url = dir.appendingPathComponent(String(format: "%04d.png", i))
            let dest = try #require(CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil))
            CGImageDestinationAddImage(dest, image, nil)
            #expect(CGImageDestinationFinalize(dest))
        }
    }
}
