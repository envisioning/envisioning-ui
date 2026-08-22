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

    public init(
        productName: String,
        phase: EnvisioningEntryPhase,
        @ViewBuilder signedOut: () -> SignedOut,
        @ViewBuilder workspace: () -> Workspace
    ) {
        self.productName = productName
        self.phase = phase
        self.signedOut = signedOut()
        self.workspace = workspace()
    }

    public var body: some View {
        switch phase {
        case .signedOut:
            signedOut
                .accessibilityIdentifier("envisioning.entry.signed-out")
        case .preparingWorkspace:
            EnvisioningWorkspaceTransition(productName: productName)
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
