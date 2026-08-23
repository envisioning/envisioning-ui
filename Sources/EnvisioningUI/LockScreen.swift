import SwiftUI

/// The shared cover shown while an Envisioning app is protected by device
/// authentication.
///
/// The lock service remains app-owned because each app has its own preference
/// and lifecycle. The presentation does not: mark, spacing, copy pattern,
/// button treatment, failure colour, and system surface all come from here.
///
/// `appName` is required rather than read from `Bundle.main`, because the lock
/// covers more than the app target. An extension reads its own bundle name, and
/// "Unlock Share Extension" is not what the person is unlocking.
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
        VStack(spacing: 20) {
            Spacer(minLength: 0)
            EnvisioningMark.view(size: 44)
            VStack(spacing: 6) {
                Text("\(appName) is locked")
                    .font(.title3.weight(.semibold))
                    .accessibilityAddTraits(.isHeader)
                Text("Unlock with \(biometricTitle) to continue.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            if let failure {
                Text(failure)
                    .font(.footnote)
                    .foregroundStyle(EnvisioningSemantics.danger)
                    .multilineTextAlignment(.center)
                    .accessibilityLabel("Unlock error: \(failure)")
            }
            Button(action: unlock) {
                Label(EnvisioningCopy.unlock, systemImage: biometricSymbolName)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(EnvisioningFilledButtonStyle())
            .controlSize(.large)
            .disabled(isAuthenticating)
            .accessibilityHint("Authenticates with \(biometricTitle) or the device passcode")
            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: 420)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background, ignoresSafeAreaEdges: .all)
    }
}
