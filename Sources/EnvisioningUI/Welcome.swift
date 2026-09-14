import SwiftUI

/// The shared first-launch composition. Apps provide only their product copy
/// and product-specific controls; the mark, type scale, card geometry, spacing,
/// and build line stay aligned.
public struct EnvisioningWelcomeShell<Content: View>: View {
    private let productName: String
    private let subtitle: String
    private let content: Content
    private let showsVersionLine: Bool
    private let environment: String?

    /// `environment` names the server this build talks to ("Production",
    /// "Local", a host). It is the first thing anybody is asked when they report
    /// something, so it belongs on the same line as the build number.
    public init(
        productName: String,
        subtitle: String,
        showsVersionLine: Bool = true,
        environment: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.productName = productName
        self.subtitle = subtitle
        self.showsVersionLine = showsVersionLine
        self.environment = environment
        self.content = content()
    }

    private static var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: EnvisioningRadius.card, style: .continuous)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 24 crowds the mark against the status bar on a phone.
                Spacer(minLength: 56)

                VStack(spacing: 12) {
                    EnvisioningMark.view(size: 44)

                    Text(productName)
                        .font(EnvisioningFont.octa(32, weight: .medium))
                        .accessibilityAddTraits(.isHeader)

                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                // The card is a container, and it has to say so: on iOS 26 the
                // fields and buttons an app puts inside resolve their corners
                // from the nearest `containerShape`. A `.background(_:in:)`
                // alone paints the rounded card but declares no container, so
                // every control inside rendered square (envisioning/meet, the
                // first-run card). Keep the shape and the container in step.
                content
                    .frame(maxWidth: 520, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 28)
                    .containerShape(Self.cardShape)
                    // The panel rung, not a system material: material blurs
                    // the canvas into a neutral gray that reads as foreign
                    // next to the slate ladder every other card uses.
                    .background(EnvisioningSurface.panel, in: Self.cardShape)
                    .overlay(Self.cardShape.stroke(EnvisioningSurface.border, lineWidth: 1))

                if showsVersionLine {
                    EnvisioningVersionLine(environment: environment)
                        .padding(.top, 14)
                }

                Spacer(minLength: 24)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
    }
}

/// Shared version placement for first-launch and about surfaces.
public struct EnvisioningVersionLine: View {
    private let environment: String?

    /// Pass the server name to append it: `Version 1.0.0 · Build 245 · Production`.
    public init(environment: String? = nil) {
        self.environment = environment
    }

    public var body: some View {
        let marketing = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "–"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "–"
        let suffix = environment.map { " · " + $0 } ?? ""

        Text("Version \(marketing) · Build \(build)" + suffix)
            .font(.caption)
            .foregroundStyle(.secondary)
            .accessibilityLabel("Version \(marketing), build \(build)" + suffix.replacingOccurrences(of: " · ", with: ", "))
    }
}

/// Shared hand-off state after authentication succeeds and before the app's
/// first signed-in surface is ready.
public struct EnvisioningWorkspaceTransition: View {
    private let productName: String

    public init(productName: String) {
        self.productName = productName
    }

    public var body: some View {
        VStack(spacing: 16) {
            EnvisioningMark.view(size: 36)
            ProgressView()
            Text("Opening \(productName)…")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Opening \(productName)")
    }
}
