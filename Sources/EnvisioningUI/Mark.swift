import SwiftUI

/// The EV mark: a seven-unit block and a tapered bar, on a 19.6-unit square.
///
/// Geometry traced from `envisioning.com/public/images/logo/symbol.svg`. The two
/// SVG copies that previously lived in the Core and Meet repos were verified to be
/// the *same* path — Core's coordinates are these multiplied by 12.190476, matching
/// to 2.5e-5 — so nothing was lost by collapsing them to one definition here.
///
/// A `Shape` rather than an asset, on purpose. Meet drew this in a `Canvas`, which
/// WidgetKit refuses, and so had to keep a second copy as a template imageset just
/// for the tab bar. A `Shape` renders in the app, the tab bar and a Live Activity
/// alike, at any size, in whatever the current foreground style is.
public struct EnvisioningMark: Shape {
    /// Side of the design grid the coordinates below are expressed in.
    private static let grid: CGFloat = 19.6

    public init() {}

    public func path(in rect: CGRect) -> Path {
        // Square and centred, so the mark never distorts in a non-square frame.
        let side = min(rect.width, rect.height)
        let k = side / Self.grid
        let dx = rect.minX + (rect.width - side) / 2
        let dy = rect.minY + (rect.height - side) / 2
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: dx + x * k, y: dy + y * k)
        }

        var path = Path()

        // The block.
        path.addRect(CGRect(origin: p(0, 6.29944), size: CGSize(width: 7 * k, height: 7 * k)))

        // The bar, tapering inward as it descends.
        path.move(to: p(16.800025, 19.6))
        path.addLine(to: p(9.8, 19.6))
        path.addLine(to: p(9.8, 14.7))
        path.addCurve(
            to: p(9.93468048, 13.73848),
            control1: p(9.8, 14.37478),
            control2: p(9.84529016, 14.05117)
        )
        path.addLine(to: p(12.60001, 4.40979))
        path.addLine(to: p(12.60001, 0))
        path.addLine(to: p(19.600035, 0))
        path.addLine(to: p(19.600035, 4.9))
        path.addCurve(
            to: p(19.46535452, 5.86152),
            control1: p(19.600035, 5.22522),
            control2: p(19.55474484, 5.54883)
        )
        path.addLine(to: p(16.800025, 15.19021))
        path.addLine(to: p(16.800025, 19.6))
        path.closeSubpath()

        return path
    }
}

extension EnvisioningMark {
    /// Convenience for the common case: the mark at a given side, in one colour.
    public static func view(size: CGFloat, tint: Color = .primary) -> some View {
        EnvisioningMark()
            .fill(tint)
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

#if canImport(UIKit)
import UIKit

extension EnvisioningMark {
    /// A template `UIImage` of the mark, for the API that will only take an
    /// image: `.tabItem`, `UITabBarItem`, notification attachments.
    ///
    /// This exists because an SVG in an asset catalog is at the mercy of Xcode's
    /// SVG parser, which silently drops shapes it cannot read — a grouped
    /// `transform` is enough to render the whole imageset blank, with no build
    /// error to warn you. Rasterising the `Shape` ourselves removes that parser
    /// from the path entirely: what compiles is what draws.
    ///
    /// Rendered as `.alwaysTemplate`, so the tab bar tints it — accent when
    /// selected, secondary when not.
    public static func templateImage(size: CGFloat = 24) -> UIImage {
        let bounds = CGRect(x: 0, y: 0, width: size, height: size)
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let image = renderer.image { context in
            context.cgContext.addPath(EnvisioningMark().path(in: bounds).cgPath)
            context.cgContext.setFillColor(UIColor.black.cgColor)
            context.cgContext.fillPath()
        }
        return image.withRenderingMode(.alwaysTemplate)
    }
}
#endif
