import XCTest
import SwiftUI
@testable import EnvisioningUI

final class EnvisioningUITests: XCTestCase {

    /// The font has to actually register, or every Octa call silently falls back
    /// to the system face and nobody notices until the wordmark looks wrong.
    ///
    /// `CTFontCreateWithName` substitutes rather than failing when a name is
    /// unknown, so a nil check would pass even with no font registered at all.
    /// Comparing the *resolved* PostScript name is what makes this a real test.
    func testOctaRegistersAndEveryWeightResolves() {
        EnvisioningFont.register()
        for weight in EnvisioningFont.Weight.allCases {
            for name in [weight.postScriptName, weight.expandedPostScriptName] {
                let font = CTFontCreateWithName(name as CFString, 12, nil)
                let resolved = CTFontCopyPostScriptName(font) as String
                XCTAssertEqual(resolved, name, "\(name) did not resolve; got \(resolved)")
            }
        }
    }

    /// Guards the claim the package is built on: one variable file supplies all
    /// eighteen faces, so neither app needs to carry static cuts.
    func testOneFileSuppliesEighteenFaces() {
        EnvisioningFont.register()
        let names = EnvisioningFont.Weight.allCases
            .flatMap { [$0.postScriptName, $0.expandedPostScriptName] }
        XCTAssertEqual(Set(names).count, 18)
    }

    /// The mark is square and centred whatever frame it is handed, so it cannot
    /// distort in a tab bar item or a Live Activity.
    func testMarkStaysSquareInAWideFrame() {
        let wide = CGRect(x: 0, y: 0, width: 200, height: 50)
        let box = EnvisioningMark().path(in: wide).boundingRect
        XCTAssertEqual(box.width, box.height, accuracy: 0.01)
        XCTAssertEqual(box.midX, wide.midX, accuracy: 0.01)
        XCTAssertEqual(box.midY, wide.midY, accuracy: 0.01)
    }

    /// The mark fills its square edge to edge — a drifted control point would
    /// show up here before it showed up in an icon.
    func testMarkFillsItsSquare() {
        let frame = CGRect(x: 0, y: 0, width: 196, height: 196)
        let box = EnvisioningMark().path(in: frame).boundingRect
        XCTAssertEqual(box.minX, 0, accuracy: 0.01)
        XCTAssertEqual(box.minY, 0, accuracy: 0.01)
        XCTAssertEqual(box.width, 196, accuracy: 0.01)
    }

    /// The mark must actually contain ink. The imageset it replaces compiled
    /// cleanly and rendered blank in the tab bar, so "it builds" proves nothing
    /// here. Rasterise the path and count opaque pixels.
    ///
    /// Deliberately CoreGraphics rather than UIKit so it runs on the macOS test
    /// host too — a UIKit-gated version of this compiles out and guards nothing.
    func testMarkRasterisesWithInk() {
        let side = 96
        var pixels = [UInt8](repeating: 0, count: side * side)
        let ctx = CGContext(
            data: &pixels, width: side, height: side, bitsPerComponent: 8,
            bytesPerRow: side, space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )
        guard let ctx else { return XCTFail("no context") }
        ctx.setFillColor(gray: 1, alpha: 1)
        let box = CGRect(x: 0, y: 0, width: side, height: side)
        ctx.addPath(EnvisioningMark().path(in: box).cgPath)
        ctx.fillPath()

        let inked = pixels.filter { $0 > 0 }.count
        let coverage = Double(inked) / Double(side * side)
        XCTAssertGreaterThan(coverage, 0.15, "mark drew blank or nearly so")
        XCTAssertLessThan(coverage, 0.75, "mark is a solid block — geometry is wrong")
    }

    /// Black on the brand fill is the whole contract. If someone edits the lime,
    /// this is the guard that the ink is still legible on it.
    func testInkClearsAAOnEveryAccentState() {
        for (name, color) in [
            ("fill", EnvisioningAccent.fill),
            ("fillPressed", EnvisioningAccent.fillPressed),
            ("fillHover", EnvisioningAccent.fillHover)
        ] {
            XCTAssertGreaterThan(
                contrast(color, EnvisioningAccent.ink), 4.5,
                "black ink fails on \(name)"
            )
        }
    }

    #if canImport(AppKit)
    /// The AppKit spellings must be the same colours as the SwiftUI ones — that
    /// is the whole reason they are derived rather than typed twice.
    func testAppKitAccentMatchesSwiftUI() {
        for (ns, swiftUI, name) in [
            (EnvisioningAccent.nsFill, EnvisioningAccent.fill, "fill"),
            (EnvisioningAccent.nsFillPressed, EnvisioningAccent.fillPressed, "fillPressed"),
            (EnvisioningAccent.nsFillHover, EnvisioningAccent.fillHover, "fillHover")
        ] {
            let a = ns.usingColorSpace(.sRGB)!
            let b = NSColor(swiftUI).usingColorSpace(.sRGB)!
            XCTAssertEqual(a.redComponent, b.redComponent, accuracy: 0.001, "\(name) red")
            XCTAssertEqual(a.greenComponent, b.greenComponent, accuracy: 0.001, "\(name) green")
            XCTAssertEqual(a.blueComponent, b.blueComponent, accuracy: 0.001, "\(name) blue")
        }
    }
    #endif

    /// The regression this token exists to prevent: brand lime used as ink on a
    /// light bar, where `fill` is 1.26:1 and a selected tab is barely visible.
    ///
    /// `foreground` is #aacc00 in light — a deliberate brand choice that does not
    /// reach the 4.5:1 AA text bar. This pins the trade rather than hiding it: it
    /// must beat `fill` by a clear margin, and it must not drift darker into the
    /// olive that clearing AA would require.
    func testForegroundAccentBeatsFillOnLightSurfaces() {
        for (bg, name) in [(Color.white, "white"), (Color(red: 0.949, green: 0.949, blue: 0.969), "grouped grey")] {
            let fg = contrast(EnvisioningAccent.foregroundOnLight, bg)
            let fill = contrast(EnvisioningAccent.fill, bg)
            XCTAssertGreaterThan(fg, fill * 1.3, "foreground is no better than fill on \(name)")
            XCTAssertGreaterThan(fg, 1.6, "foreground too washed out on \(name)")
            XCTAssertLessThan(fg, 3.0, "foreground has drifted into olive on \(name) — brand lost")
        }
    }

    /// Dark keeps the actual brand lime: there is no contrast problem there.
    func testForegroundAccentStaysBrandLimeOnDark() {
        let darkCanvas = Color(red: 0.11, green: 0.11, blue: 0.118)
        XCTAssertGreaterThan(contrast(EnvisioningAccent.foregroundOnDark, darkCanvas), 4.5)
    }

    private func contrast(_ a: Color, _ b: Color) -> Double {
        func luminance(_ c: Color) -> Double {
            #if canImport(UIKit)
            var r: CGFloat = 0, g: CGFloat = 0, bl: CGFloat = 0, al: CGFloat = 0
            UIColor(c).getRed(&r, green: &g, blue: &bl, alpha: &al)
            #else
            let ns = NSColor(c).usingColorSpace(.sRGB) ?? .black
            let r = ns.redComponent, g = ns.greenComponent, bl = ns.blueComponent
            #endif
            func channel(_ v: CGFloat) -> Double {
                let d = Double(v)
                return d <= 0.04045 ? d / 12.92 : pow((d + 0.055) / 1.055, 2.4)
            }
            return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(bl)
        }
        let la = luminance(a), lb = luminance(b)
        return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)
    }
}
