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
    /// build. Reads `envisioningListSurface` from the environment: `.clear`
    /// paints nothing, so a half-height sheet on iOS 26 shows its own glass
    /// under the rows.
    public func envisioningListSurface() -> some View {
        modifier(EnvisioningListSurfaceModifier())
    }
}

/// What a list or form paints under its rows.
public enum EnvisioningListSurface: Sendable {
    /// The canvas rung, the default everywhere.
    case canvas
    /// Nothing. For content inside a container that draws its own ground —
    /// a partial-height sheet on iOS 26. The navigation container's
    /// background is cleared too, so a `NavigationStack` root does not
    /// paint the system's opaque ground in its place.
    case clear
}

private struct EnvisioningListSurfaceKey: EnvironmentKey {
    static let defaultValue = EnvisioningListSurface.canvas
}

extension EnvironmentValues {
    public var envisioningListSurface: EnvisioningListSurface {
        get { self[EnvisioningListSurfaceKey.self] }
        set { self[EnvisioningListSurfaceKey.self] = newValue }
    }
}

private struct EnvisioningListSurfaceModifier: ViewModifier {
    @Environment(\.envisioningListSurface) private var surface

    func body(content: Content) -> some View {
        switch surface {
        case .canvas:
            content
                .scrollContentBackground(.hidden)
                .background(EnvisioningSurface.canvas.ignoresSafeArea())
        case .clear:
            #if os(iOS)
            if #available(iOS 18.0, *) {
                content
                    .scrollContentBackground(.hidden)
                    .containerBackground(.clear, for: .navigation)
            } else {
                content.scrollContentBackground(.hidden)
            }
            #else
            content.scrollContentBackground(.hidden)
            #endif
        }
    }
}

private enum EnvisioningListRowFill {
    #if os(iOS)
    static let color = EnvisioningSurface.panel
    #else
    static let color = Color.clear
    #endif
}
