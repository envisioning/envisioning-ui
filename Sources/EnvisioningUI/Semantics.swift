import SwiftUI

/// State colours the platform has no opinion about.
///
/// Surfaces and text tones are next door in `EnvisioningSurface`. This file
/// used to say they were "the system's job"; leaving them to the system is
/// what put a neutral-gray Core pane inside a blue-tinted Meet window
/// (envisioning/meet#140), so the estate now owns one ladder and every app
/// stands on it.
public enum EnvisioningSemantics {
    /// Destructive, failed, or live-and-should-not-be.
    public static let danger = adaptive(
        dark: (1.00, 0.39, 0.38),
        light: (0.74, 0.12, 0.14)
    )

    /// Spoken for, but nothing is live. Amber rather than red.
    public static let busy = adaptive(
        dark: (0.949, 0.710, 0.267),
        light: (0.72, 0.43, 0.04)
    )

    /// Informational overlay — a public event on a shared agenda.
    public static let publicEvent = Color(red: 0.42, green: 0.74, blue: 0.90)

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
            // Dark first: for an appearance such as `.vibrantDark`, AppKit picks
            // the best match from the order given, not from the enum order.
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            let v = isDark ? dark : light
            return NSColor(srgbRed: v.0, green: v.1, blue: v.2, alpha: 1)
        })
        #else
        return Color(red: light.0, green: light.1, blue: light.2)
        #endif
    }
}
