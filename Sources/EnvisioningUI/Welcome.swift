import SwiftUI

/// The shared first-launch composition. Apps provide only their product copy
/// and product-specific controls; the mark, type scale, card geometry, spacing,
/// and build line stay aligned.
public struct EnvisioningWelcomeShell<Content: View>: View {
    private let productName: String
    private let subtitle: String
    private let content: Content
    private let showsVersionLine: Bool

    public init(
        productName: String,
        subtitle: String,
        showsVersionLine: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.productName = productName
        self.subtitle = subtitle
        self.showsVersionLine = showsVersionLine
        self.content = content()
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 24)

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

                content
                    .frame(maxWidth: 520, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 28)
                    .background(
                        .regularMaterial,
                        in: RoundedRectangle(cornerRadius: EnvisioningRadius.card, style: .continuous)
                    )

                if showsVersionLine {
                    EnvisioningVersionLine()
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
    public init() {}

    public var body: some View {
        let marketing = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "–"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "–"

        Text("Version \(marketing) · build \(build)")
            .font(.caption)
            .foregroundStyle(.secondary)
            .accessibilityLabel("Version \(marketing), build \(build)")
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
