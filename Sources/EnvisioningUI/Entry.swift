import SwiftUI

/// The three app-entry phases shared by Envisioning products.
///
/// Apps decide when their workspace is usable. The shell decides which common
/// surface that state presents, keeping launch and sign-in transitions aligned.
public enum EnvisioningEntryPhase: Equatable, Sendable {
    case signedOut
    case preparingWorkspace
    case ready
}

public struct EnvisioningEntryGate<SignedOut: View, Workspace: View>: View {
    private let productName: String
    private let phase: EnvisioningEntryPhase
    private let signedOut: SignedOut
    private let workspace: Workspace
    /// The product's own mark for the transition; nil draws the Envisioning mark.
    private let mark: AnyView?

    public init(
        productName: String,
        phase: EnvisioningEntryPhase,
        mark: AnyView? = nil,
        @ViewBuilder signedOut: () -> SignedOut,
        @ViewBuilder workspace: () -> Workspace
    ) {
        self.productName = productName
        self.phase = phase
        self.mark = mark
        self.signedOut = signedOut()
        self.workspace = workspace()
    }

    public var body: some View {
        switch phase {
        case .signedOut:
            signedOut
                .accessibilityIdentifier("envisioning.entry.signed-out")
        case .preparingWorkspace:
            EnvisioningWorkspaceTransition(productName: productName, mark: mark)
                .accessibilityIdentifier("envisioning.entry.preparing-workspace")
        case .ready:
            workspace
                .accessibilityIdentifier("envisioning.entry.ready")
        }
    }
}

#if canImport(UIKit)
import UIKit

/// The canonical Home tab label: one word and the EV glyph rendered through
/// the package's template-image path.
public struct EnvisioningHomeTabLabel: View {
    public init() {}

    public var body: some View {
        Label {
            Text("Home")
        } icon: {
            Image(uiImage: EnvisioningMark.templateImage())
        }
    }
}
#endif
