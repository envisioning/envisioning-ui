import SwiftUI
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif

/// The surface ladder every Envisioning app stands on, in both appearances.
///
/// One set of numbers, three projections (`Color`, `NSColor`, `UIColor`), so a
/// SwiftUI view from `core-kit` hosted inside an AppKit window in Meet paints
/// the same rung as the window around it. Before this lived here, Meet mixed
/// its own ladder, Core reached for the system's grouped grays, and the seam
/// between them was visible on every Core-shaped pane (envisioning/meet#140).
///
/// Dark is a touch blue — canvas `#202128`, panel `#292a32`, elevated
/// `#343640`, well `#1a1b21` — because pure neutral gray reads as unfinished
/// beside the lime. Light is the same ladder in neutral gray: the rungs encode
/// depth and nothing else, so they carry no hue.
///
/// | rung            | dark      | light     |
/// |-----------------|-----------|-----------|
/// | `canvas`        | `#202128` | `#efefef` |
/// | `panel`         | `#292a32` | `#f6f6f6` |
/// | `elevated`      | `#343640` | `#ffffff` |
/// | `field`         | `#1a1b21` | `#e4e4e4` |
/// | `primaryText`   | `#fafafa` | `#1a1a1a` |
/// | `secondaryText` | `#a3a3a3` | `#5c5c5c` |
///
/// Borders and the hover lift are white or black at an alpha, so they sit on
/// any rung without a colour of their own. The web mirrors the same table as
/// `--surface-*` custom properties; `Token.hex(dark:)` is what a mirror test
/// compares against.
public enum EnvisioningSurface {
    public enum Token: String, CaseIterable, Sendable {
        /// The window or page behind everything.
        case canvas
        /// A sidebar, a card's ground, a sheet.
        case panel
        /// One rung up: a popover, a raised tile, a row under the pointer.
        case elevated
        /// Sunken fill for typed inputs; reads as a well on `panel` and `elevated`.
        case field
        /// Hairline between regions.
        case border
        /// The same hairline under the pointer.
        case borderHover
        /// A half-step stronger than `border`, for a control that must read
        /// as a button at a glance rather than on hover.
        case controlBorder
        case primaryText
        case secondaryText
        /// One rung up as a veil, so a call site never names the colour it lifts.
        case hoverLift

        /// sRGB components with alpha, for the given appearance. The one
        /// source; every projection below derives from it.
        public func rgba(dark: Bool) -> (red: Double, green: Double, blue: Double, alpha: Double) {
            switch (self, dark) {
            case (.canvas, true): return (0.125, 0.129, 0.157, 1)
            case (.canvas, false): return (0.937, 0.937, 0.937, 1)
            case (.panel, true): return (0.161, 0.165, 0.196, 1)
            case (.panel, false): return (0.965, 0.965, 0.965, 1)
            case (.elevated, true): return (0.204, 0.212, 0.251, 1)
            case (.elevated, false): return (1, 1, 1, 1)
            case (.field, true): return (0.102, 0.106, 0.129, 1)
            case (.field, false): return (0.894, 0.894, 0.894, 1)
            case (.border, true): return (1, 1, 1, 0.10)
            case (.border, false): return (0, 0, 0, 0.14)
            case (.borderHover, true): return (1, 1, 1, 0.20)
            case (.borderHover, false): return (0, 0, 0, 0.26)
            case (.controlBorder, true): return (1, 1, 1, 0.16)
            case (.controlBorder, false): return (0, 0, 0, 0.22)
            case (.primaryText, true): return (0.980, 0.980, 0.980, 1)
            case (.primaryText, false): return (0.102, 0.102, 0.102, 1)
            case (.secondaryText, true): return (0.639, 0.639, 0.639, 1)
            case (.secondaryText, false): return (0.361, 0.361, 0.361, 1)
            case (.hoverLift, true): return (1, 1, 1, 0.06)
            case (.hoverLift, false): return (0, 0, 0, 0.06)
            }
        }

        /// `#rrggbb` for an opaque rung — what a stylesheet writes. Nil for the
        /// alpha rungs, which a stylesheet spells as `rgb(... / a)`.
        public func hex(dark: Bool) -> String? {
            let v = rgba(dark: dark)
            guard v.alpha == 1 else { return nil }
            return String(format: "#%02x%02x%02x", Int((v.red * 255).rounded()), Int((v.green * 255).rounded()), Int((v.blue * 255).rounded()))
        }
    }

    // MARK: SwiftUI

    public static let canvas = color(.canvas)
    public static let panel = color(.panel)
    public static let elevated = color(.elevated)
    public static let field = color(.field)
    public static let border = color(.border)
    public static let borderHover = color(.borderHover)
    public static let controlBorder = color(.controlBorder)
    public static let primaryText = color(.primaryText)
    public static let secondaryText = color(.secondaryText)
    public static let hoverLift = color(.hoverLift)

    public static func color(_ token: Token) -> Color {
        #if canImport(UIKit)
        return Color(uiColor: uiColor(token))
        #elseif canImport(AppKit)
        return Color(nsColor: nsColor(token))
        #else
        let v = token.rgba(dark: false)
        return Color(red: v.red, green: v.green, blue: v.blue, opacity: v.alpha)
        #endif
    }

    #if canImport(AppKit)
    // MARK: AppKit

    /// Dynamic: resolves against the view's effective appearance each draw.
    public static func nsColor(_ token: Token) -> NSColor {
        NSColor(name: nil) { appearance in
            // Dark first: for `.vibrantDark`, AppKit picks the best match from
            // the order given, not from the enum order.
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            let v = token.rgba(dark: isDark)
            return NSColor(srgbRed: v.red, green: v.green, blue: v.blue, alpha: v.alpha)
        }
    }
    #endif

    #if canImport(UIKit)
    // MARK: UIKit

    public static func uiColor(_ token: Token) -> UIColor {
        UIColor { traits in
            let v = token.rgba(dark: traits.userInterfaceStyle == .dark)
            return UIColor(red: v.red, green: v.green, blue: v.blue, alpha: v.alpha)
        }
    }
    #endif
}
