import SwiftUI

/// The brand call to action: lime fill, black ink.
///
/// Press outranks hover. The pointer is by definition still inside the button
/// while it is held, so a hover fill checked first would never let go.
public struct EnvisioningFilledButtonStyle: ButtonStyle {
    private let minHeight: CGFloat
    private let expands: Bool

    public init(minHeight: CGFloat = 48, expands: Bool = true) {
        self.minHeight = minHeight
        self.expands = expands
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(EnvisioningAccent.ink)
            .padding(.horizontal, expands ? 0 : 20)
            .frame(maxWidth: expands ? .infinity : nil, minHeight: minHeight)
            .modifier(FillFor(pressed: configuration.isPressed))
    }
}

/// The quiet sibling: system surface, system ink, brand geometry.
public struct EnvisioningBorderedButtonStyle: ButtonStyle {
    private let minHeight: CGFloat
    private let expands: Bool

    public init(minHeight: CGFloat = 46, expands: Bool = true) {
        self.minHeight = minHeight
        self.expands = expands
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.primary)
            .padding(.horizontal, expands ? 0 : 20)
            .frame(maxWidth: expands ? .infinity : nil, minHeight: minHeight)
            .background(
                .quaternary.opacity(configuration.isPressed ? 0.7 : 1),
                in: RoundedRectangle(cornerRadius: EnvisioningRadius.control, style: .continuous)
            )
    }
}

/// Swaps the fill rather than veiling it: an opaque veil would bury black ink.
private struct FillFor: ViewModifier {
    let pressed: Bool
    @State private var hovered = false

    func body(content: Content) -> some View {
        content
            .background(
                resolved,
                in: RoundedRectangle(cornerRadius: EnvisioningRadius.control, style: .continuous)
            )
            .onHover { hovered = $0 }
    }

    private var resolved: Color {
        if pressed { return EnvisioningAccent.fillPressed }
        return hovered ? EnvisioningAccent.fillHover : EnvisioningAccent.fill
    }
}

extension ButtonStyle where Self == EnvisioningFilledButtonStyle {
    public static var envisioningFilled: EnvisioningFilledButtonStyle { .init() }
}

extension ButtonStyle where Self == EnvisioningBorderedButtonStyle {
    public static var envisioningBordered: EnvisioningBorderedButtonStyle { .init() }
}
