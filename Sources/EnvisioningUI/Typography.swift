import EnvisioningOcta
import SwiftUI

/// Envisioning Octa, as this design system uses it.
///
/// The face itself — and its registration — live in the `envisioning-octa`
/// package, which vends the exact file its `build.sh` produces. There is one
/// `EnvisioningOcta-VF.ttf` in the estate and neither app carries a copy.
public enum EnvisioningFont {
    /// Re-exported so call sites name weights without importing the font package.
    public typealias Weight = EnvisioningOcta.Face

    /// Idempotent. `octa(_:weight:expanded:)` calls this for you.
    public static func register() { EnvisioningOcta.register() }

    /// Octa at a fixed size.
    ///
    /// Fixed, not scaled: Octa is a display face — a clock, a wordmark — where
    /// reflowing to an accessibility size breaks the layout it anchors. Body text
    /// stays on the system face, which does scale.
    public static func octa(
        _ size: CGFloat,
        weight: Weight = .medium,
        expanded: Bool = false
    ) -> Font {
        register()
        return .custom(expanded ? weight.expandedPostScriptName : weight.postScriptName, fixedSize: size)
    }
}
