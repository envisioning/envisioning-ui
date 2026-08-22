import SwiftUI

/// A blocking initial load. In-place refreshes should keep their content and
/// use the platform's smaller progress treatment instead.
public struct EnvisioningLoadingState: View {
    private let label: String

    public init(_ label: String) {
        self.label = label
    }

    public var body: some View {
        ProgressView(label)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
    }
}

/// A full-surface empty state using the platform component and shared spacing.
public struct EnvisioningEmptyState: View {
    private let title: String
    private let systemImage: String
    private let message: String?

    public init(_ title: String, systemImage: String, message: String? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.message = message
    }

    public var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            if let message { Text(message) }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// A blocking recoverable failure with one canonical recovery action.
public struct EnvisioningRetryState: View {
    private let title: String
    private let systemImage: String
    private let message: String
    private let action: () -> Void

    public init(
        _ title: String,
        systemImage: String = "exclamationmark.triangle",
        message: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.message = message
        self.action = action
    }

    public var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
        } actions: {
            Button(EnvisioningCopy.tryAgain, action: action)
                .buttonStyle(EnvisioningBorderedButtonStyle(expands: false))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
    }
}

/// The compact counterpart for a list row or banner. Its container remains
/// app-owned because system surfaces differ by context.
public struct EnvisioningInlineRetry: View {
    private let message: String
    private let action: () -> Void

    public init(_ message: String, action: @escaping () -> Void) {
        self.message = message
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                Text(message)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 8)
                Text(EnvisioningCopy.tryAgain)
                    .fontWeight(.medium)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(message). \(EnvisioningCopy.tryAgain)")
    }
}
