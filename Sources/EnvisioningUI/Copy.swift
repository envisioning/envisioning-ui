import Foundation

/// User-facing wording shared by Envisioning apps.
///
/// Provider names belong in implementation diagnostics, not in the primary
/// action a person taps. The identity is Envisioning; Google is one of the
/// current ways that identity is verified.
public enum EnvisioningCopy {
    public static let signInWithEnvisioning = "Sign in with Envisioning"
    public static let signingIn = "Signing in…"
    public static let signInCancelled = "Sign-in cancelled. Try again."
    public static let signInFailed = "Sign-in couldn’t be completed. Try again."
    public static let unlock = "Unlock"
    public static let biometricUnavailable =
        "Set up Face ID, Touch ID, or a device passcode in the Settings app first."
    public static let biometricCouldNotConfirm = "Could not confirm it is you."
    public static let continueLabel = "Continue"
    public static let orLabel = "or"
    public static let signOut = "Sign out"
    public static let signedInWithEnvisioning = "Signed in with your Envisioning account."
    public static let signOutDescription =
        "Removes this device’s session. You can sign in again with Envisioning."
    public static let done = "Done"
    public static let tryAgain = "Try again"

    /// The system Face ID / Touch ID sheet renders nothing but this line, so it
    /// has to name the app that is asking. A person with more than one
    /// Envisioning app installed otherwise sees the same prompt from both.
    public static func unlockReason(app: String) -> String {
        "Unlock \(app)"
    }

    /// Same reason, for the two prompts that guard the setting itself.
    public static func appLockReason(app: String, enabling: Bool) -> String {
        enabling ? "Turn on the \(app) app lock" : "Turn off the \(app) app lock"
    }
}
