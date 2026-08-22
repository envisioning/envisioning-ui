import SwiftUI

/// A per-app appearance preference.
///
/// `auto` means the device's setting, not "whatever the app last used" — the
/// distinction matters, because an app that remembers its own last theme stops
/// following the system at dusk and users read that as a bug.
///
/// The mode is shared; the storage key is not. Each app passes its own, so Core
/// and Meet can be set differently on one device and neither migration disturbs
/// the other's saved preference.
public enum EnvisioningAppearanceMode: String, CaseIterable, Hashable, Identifiable, Sendable {
    case auto
    case light
    case dark

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .auto: return "Auto"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    public var detail: String {
        switch self {
        case .auto: return "Follow this device's appearance"
        case .light: return "Always use the light appearance"
        case .dark: return "Always use the dark appearance"
        }
    }

    /// What to hand `.preferredColorScheme`. `nil` lets the system decide, which
    /// is what `auto` means.
    public var colorScheme: ColorScheme? {
        switch self {
        case .auto: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    public static func mode(forKey key: String, defaults: UserDefaults = .standard) -> Self {
        guard let raw = defaults.string(forKey: key), let mode = Self(rawValue: raw) else { return .auto }
        return mode
    }
}

/// The canonical appearance control used inside an app's Appearance pane.
public struct EnvisioningAppearancePicker: View {
    @Binding private var selection: String

    public init(selection: Binding<String>) {
        _selection = selection
    }

    private var mode: EnvisioningAppearanceMode {
        EnvisioningAppearanceMode(rawValue: selection) ?? .auto
    }

    public var body: some View {
        Picker("Appearance", selection: $selection) {
            ForEach(EnvisioningAppearanceMode.allCases) { mode in
                Text(mode.title).tag(mode.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()

        Text(mode.detail)
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}
