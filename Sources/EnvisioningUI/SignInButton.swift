import SwiftUI

public enum EnvisioningButtonProminence: Equatable {
    case filled
    case bordered
}

/// The canonical Envisioning sign-in action. The prominence changes by context
/// (CORE has only one action; MEET also offers guest joining), while its wording
/// and loading state remain identical.
public struct EnvisioningSignInButton: View {
    private let isLoading: Bool
    private let prominence: EnvisioningButtonProminence
    private let action: () -> Void

    public init(
        isLoading: Bool = false,
        prominence: EnvisioningButtonProminence = .filled,
        action: @escaping () -> Void
    ) {
        self.isLoading = isLoading
        self.prominence = prominence
        self.action = action
    }

    public var body: some View {
        Group {
            if prominence == .filled {
                button
                    .buttonStyle(EnvisioningFilledButtonStyle())
            } else {
                button
                    .buttonStyle(EnvisioningBorderedButtonStyle())
            }
        }
    }

    private var button: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(prominence == .filled ? EnvisioningAccent.ink : .primary)
                }
                Text(isLoading ? EnvisioningCopy.signingIn : EnvisioningCopy.signInWithEnvisioning)
            }
        }
        .disabled(isLoading)
        .accessibilityLabel(isLoading ? EnvisioningCopy.signingIn : EnvisioningCopy.signInWithEnvisioning)
    }
}
