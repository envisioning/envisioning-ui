import SwiftUI

/// One destination in the shared Envisioning settings shell.
///
/// Apps own the controls inside a pane. The shell owns how those controls are
/// discovered and navigated, so settings feel like the same place in every app.
public struct EnvisioningSettingsPane: Identifiable {
    public let id: String
    public let title: String
    public let systemImage: String
    fileprivate let content: () -> AnyView

    public init<Content: View>(
        id: String,
        title: String,
        systemImage: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.content = { AnyView(content()) }
    }
}

/// A named set of related settings destinations.
public struct EnvisioningSettingsGroup: Identifiable {
    public let id: String
    public let title: String
    public let panes: [EnvisioningSettingsPane]

    public init(
        id: String? = nil,
        title: String,
        panes: [EnvisioningSettingsPane]
    ) {
        self.id = id ?? title
        self.title = title
        self.panes = panes
    }
}

/// The shared settings information architecture.
///
/// On iPad and Mac it is a sidebar and detail view. On iPhone the same
/// `NavigationSplitView` collapses into the familiar push-navigation list.
public struct EnvisioningSettingsShell: View {
    private let title: String
    private let groups: [EnvisioningSettingsGroup]
    private let showsDoneButton: Bool

    @Environment(\.dismiss) private var dismiss
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    @State private var selection: String?

    public init(
        title: String = "Settings",
        groups: [EnvisioningSettingsGroup],
        showsDoneButton: Bool = false
    ) {
        self.title = title
        self.groups = groups.filter { !$0.panes.isEmpty }
        self.showsDoneButton = showsDoneButton
    }

    private var allPanes: [EnvisioningSettingsPane] { groups.flatMap(\.panes) }

    public var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(groups) { group in
                    Section(group.title) {
                        ForEach(group.panes) { pane in
                            NavigationLink(value: pane.id) {
                                Label(pane.title, systemImage: pane.systemImage)
                            }
                                .accessibilityHint("Opens \(pane.title) settings")
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationSplitViewColumnWidth(min: 200, ideal: 220)
        } detail: {
            let active = allPanes.first { $0.id == selection }
            if let active {
                active.content()
                    .navigationTitle(active.title)
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
            } else {
                ContentUnavailableView("Select a Setting", systemImage: "gearshape")
            }
        }
        .toolbar {
            if showsDoneButton {
                ToolbarItem(placement: .confirmationAction) {
                    Button(EnvisioningCopy.done) { dismiss() }
                }
            }
        }
        .onAppear {
            selectInitialPaneIfNeeded()
        }
        #if os(iOS)
        .onChange(of: horizontalSizeClass) { _, _ in selectInitialPaneIfNeeded() }
        #endif
    }

    /// Compact iPhone settings start at the index. Wider layouts keep a useful
    /// detail visible, matching the native Settings presentation on iPad/Mac.
    private func selectInitialPaneIfNeeded() {
        guard selection == nil else { return }
        #if os(iOS)
        guard horizontalSizeClass == .regular else { return }
        #endif
        selection = allPanes.first?.id
    }
}

/// The shared App Lock control and explanation. Apps provide the state and the
/// authentication action; all user-facing presentation remains identical.
public struct EnvisioningAppLockSection: View {
    @Binding private var isEnabled: Bool

    private let biometricTitle: String
    private let isBiometricAvailable: Bool
    private let isChanging: Bool
    private let failure: String?
    private let graceInterval: Int
    private let onChange: (Bool) -> Void

    public init(
        isEnabled: Binding<Bool>,
        biometricTitle: String,
        isBiometricAvailable: Bool,
        isChanging: Bool,
        failure: String?,
        graceInterval: Int,
        onChange: @escaping (Bool) -> Void
    ) {
        _isEnabled = isEnabled
        self.biometricTitle = biometricTitle
        self.isBiometricAvailable = isBiometricAvailable
        self.isChanging = isChanging
        self.failure = failure
        self.graceInterval = graceInterval
        self.onChange = onChange
    }

    public var body: some View {
        Section {
            Toggle("Require \(biometricTitle)", isOn: $isEnabled)
                .disabled(isChanging || !isBiometricAvailable)
                .onChange(of: isEnabled) { _, requested in onChange(requested) }
                .accessibilityHint(
                    isBiometricAvailable
                        ? "Requires device authentication when Envisioning is locked"
                        : EnvisioningCopy.biometricUnavailable
                )

            if let failure {
                Text(failure)
                    .font(.footnote)
                    .foregroundStyle(EnvisioningSemantics.danger)
                    .accessibilityLabel("App Lock error: \(failure)")
            }
        } header: {
            Text("App Lock")
        } footer: {
            Text(explanation)
        }
    }

    private var explanation: String {
        guard isBiometricAvailable else { return EnvisioningCopy.biometricUnavailable }
        return "Envisioning asks for \(biometricTitle) on launch, and again when you come back after \(graceInterval) seconds away. The device passcode still works if \(biometricTitle) fails. This protects what is shown on screen; it does not encrypt data already stored on this device."
    }
}
