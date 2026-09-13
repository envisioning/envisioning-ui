import SwiftUI

/// The shared cover shown while an Envisioning app is protected by device
/// authentication.
///
/// Keep it quiet. The system Face ID / Touch ID sheet already names the app
/// and explains itself, and it raises on arrival — so in the common case the
/// person glances at the phone and never reads this view. It only has to hide
/// the app surface and keep the unlock action reachable: a glyph, one button,
/// and the failure text when there is one. No mark, no "<App> is locked"
/// headline, no "Unlock with Face ID to continue" subtitle. Meet shipped this
/// shape first (envisioning/meet 3981ae2); every app gets it from here.
///
/// The lock service remains app-owned because each app has its own preference
/// and lifecycle. The presentation does not.
///
/// `appName` and `biometricTitle` are still taken so callers do not change and
/// so accessibility can say what is being unlocked, which the visible copy no
/// longer does.
public struct EnvisioningLockScreen: View {
    private let appName: String
    private let biometricTitle: String
    private let biometricSymbolName: String
    private let failure: String?
    private let isAuthenticating: Bool
    private let unlock: () -> Void

    public init(
        appName: String,
        biometricTitle: String,
        biometricSymbolName: String,
        failure: String?,
        isAuthenticating: Bool,
        unlock: @escaping () -> Void
    ) {
        self.appName = appName
        self.biometricTitle = biometricTitle
        self.biometricSymbolName = biometricSymbolName
        self.failure = failure
        self.isAuthenticating = isAuthenticating
        self.unlock = unlock
    }

    public var body: some View {
        VStack(spacing: 14) {
            Image(systemName: biometricSymbolName)
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Button(action: unlock) {
                Text(isAuthenticating ? "Unlocking…" : EnvisioningCopy.unlock)
                    .frame(minWidth: 112)
            }
            .buttonStyle(EnvisioningBorderedButtonStyle())
            .controlSize(.large)
            .disabled(isAuthenticating)
            .accessibilityLabel("Unlock \(appName)")
            .accessibilityHint("Authenticates with \(biometricTitle) or the device passcode")

            if let failure {
                Text(failure)
                    .font(.footnote)
                    .foregroundStyle(EnvisioningSemantics.danger)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
                    .accessibilityLabel("Unlock error: \(failure)")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background, ignoresSafeAreaEdges: .all)
    }
}
