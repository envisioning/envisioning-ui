import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

/// The brand lime, and the one rule that governs it.
///
/// Measured contrast, sRGB:
///
/// | pairing                    | ratio    |
/// |----------------------------|----------|
/// | black on `#d6f249`         | 16.66:1  |
/// | black on `#aacc00`         | 11.35:1  |
/// | `#d6f249` as ink on white  |  1.26:1  |
/// | `#aacc00` as ink on white  |  1.85:1  |
///
/// So the lime is a **fill** carrying black ink, never ink itself on a light
/// surface. Darkening it does not rescue the foreground case: the first lime that
/// clears 3:1 against white is `#87992E`, which is an olive, not the brand.
///
/// That is why nothing here is called `accent`. A call site that writes
/// `.foregroundStyle(EnvisioningAccent.fill)` reads as wrong, which is the point —
/// the rule lives in the name rather than in a comment somebody has to find.
///
/// One value in both light and dark. The lime does not change with the scheme;
/// only the interaction state changes.
public enum EnvisioningAccent {
    // The canonical values. Everything below is derived from these, so the
    // SwiftUI and AppKit sides cannot drift apart.
    private static let fillRGB = (0.839, 0.949, 0.286)        // #d6f249
    private static let fillPressedRGB = (0.667, 0.800, 0.000) // #aacc00
    private static let fillHoverRGB = (0.878, 0.969, 0.435)   // #e0f76f

    /// Resting brand fill. `#d6f249`.
    public static let fill = Color(red: fillRGB.0, green: fillRGB.1, blue: fillRGB.2)

    /// Pressed. `#aacc00` — the down state, not a light-mode variant.
    public static let fillPressed = Color(red: fillPressedRGB.0, green: fillPressedRGB.1, blue: fillPressedRGB.2)

    /// Hovered, for pointer surfaces: iPad with a trackpad, Mac, web. `#e0f76f`.
    public static let fillHover = Color(red: fillHoverRGB.0, green: fillHoverRGB.1, blue: fillHoverRGB.2)

    /// What goes *on* the fill. Black clears 16.66:1; white manages 1.26:1.
    public static let ink = Color.black

    // Light-mode ink lime: #aacc00, the house green.
    //
    // Chosen for brand, not for contrast. As ink on white it is 1.85:1, short of
    // the 4.5:1 AA text bar — a lime dark enough to clear that lands around
    // #687523, an olive that no longer reads as the brand. #aacc00 is still a
    // clear improvement on using `fill` here, which is 1.26:1 and barely visible.
    private static let foregroundLightRGB = (0.667, 0.800, 0.000)  // #aacc00

    /// The brand colour when it has to *be* the ink rather than sit under it —
    /// a selected tab item, a chosen row, a state glyph.
    ///
    /// This is the one case `fill` cannot serve. On a light bar `fill` scores
    /// 1.26:1, so a selected tab drawn in it is barely visible. In dark there is
    /// no such problem: `fill` on `#1C1C1E` is 13.50:1, so dark keeps the lime.
    ///
    /// Light therefore uses a darkened lime of the same hue. That is the split
    /// CORE's old light/dark accent was reaching for; its `#aacc00` only reached
    /// 1.85:1, which is why the swap never actually fixed anything.
    public static let foreground = adaptive(dark: fillRGB, light: foregroundLightRGB)

    private static func adaptive(
        dark: (Double, Double, Double),
        light: (Double, Double, Double)
    ) -> Color {
        #if canImport(UIKit)
        return Color(uiColor: UIColor { traits in
            let v = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: v.0, green: v.1, blue: v.2, alpha: 1)
        })
        #elseif canImport(AppKit)
        return Color(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            let v = isDark ? dark : light
            return NSColor(srgbRed: v.0, green: v.1, blue: v.2, alpha: 1)
        })
        #else
        return Color(red: light.0, green: light.1, blue: light.2)
        #endif
    }

    /// The two resolved values, for tests and for AppKit call sites that need a
    /// concrete colour rather than a dynamic one.
    public static let foregroundOnLight = Color(red: foregroundLightRGB.0, green: foregroundLightRGB.1, blue: foregroundLightRGB.2)
    public static let foregroundOnDark = fill

    #if canImport(AppKit)
    /// AppKit spellings for the same three values. Meet's Mac app draws in
    /// `NSColor`, and it must not keep its own copy of the lime to do it.
    public static let nsFill = NSColor(srgbRed: fillRGB.0, green: fillRGB.1, blue: fillRGB.2, alpha: 1)
    public static let nsFillPressed = NSColor(srgbRed: fillPressedRGB.0, green: fillPressedRGB.1, blue: fillPressedRGB.2, alpha: 1)
    public static let nsFillHover = NSColor(srgbRed: fillHoverRGB.0, green: fillHoverRGB.1, blue: fillHoverRGB.2, alpha: 1)
    public static let nsInk = NSColor.black
    #endif
}
