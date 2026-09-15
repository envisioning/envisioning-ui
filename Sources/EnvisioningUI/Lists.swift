import SwiftUI

/// The one grouped list every Envisioning surface draws: rows on the ladder,
/// on the canvas, whichever app hosts them.
///
/// A SwiftUI `List` has two fills the system owns by default — its scroll
/// content and each row — and neither one is on the ladder. On iOS the rows
/// come out in UIKit's grouped grey (`#1c1c1e`), or black for a plain list,
/// which is what made a Core-shaped pane inside Meet read as a boxed-off
/// iframe (envisioning/meet#140). The row fill is a *trait*: only the view
/// that owns the rows can set it, so a host cannot fix this from outside —
/// the package has to draw its rows right.
///
/// iOS: `panel` rows with a `border` separator, inset-grouped, on `canvas`.
/// macOS: rows stay clear over the host's canvas (an AppKit window already
/// paints it), with the same separator; the Mac apps draw their own dense
/// AppKit lists and the grouped look is not theirs.
public struct EnvisioningList<Content: View>: View {
    @ViewBuilder private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        List {
            Group { content }
                .envisioningListRows()
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #endif
        .envisioningListSurface()
    }
}

/// `EnvisioningList` for a `Form`: the grouped style pinned, the same rows.
public struct EnvisioningForm<Content: View>: View {
    @ViewBuilder private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        Form {
            Group { content }
                .envisioningListRows()
        }
        .formStyle(.grouped)
        .envisioningListSurface()
    }
}

extension View {
    /// The rows of a `List` or `Form`, on the ladder. Apply to the content
    /// *inside* the container: on the container itself a row trait does
    /// nothing. `EnvisioningList` and `EnvisioningForm` do this for you; use
    /// it directly on a `List(data) { row }` or `List(selection:)`, whose
    /// inits the wrappers do not take.
    public func envisioningListRows() -> some View {
        self
            .listRowBackground(EnvisioningListRowFill.color)
            .listRowSeparatorTint(EnvisioningSurface.border)
    }

    /// The container half: the system's scroll background off, the canvas
    /// on. Pair with `envisioningListRows()` on a list the wrappers cannot
    /// build.
    public func envisioningListSurface() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(EnvisioningSurface.canvas.ignoresSafeArea())
    }
}

private enum EnvisioningListRowFill {
    #if os(iOS)
    static let color = EnvisioningSurface.panel
    #else
    static let color = Color.clear
    #endif
}
