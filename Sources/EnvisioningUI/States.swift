import SwiftUI

// Where a wait is drawn — the house rule, in order of preference:
//
// 1. Nothing. A screen with a snapshot paints it and refreshes behind it.
// 2. `EnvisioningPlaceholderRows` in the section the answer will fill: a
//    list on its first open keeps its shape, and the real rows land in place.
//    Nothing ever floats over the content.
// 3. A small `ProgressView` *in the control that is busy* — replacing a
//    button's label, at the trailing end of the row whose action runs, in the
//    last row while a next page loads. The row it belongs to, not the screen.
// 4. `EnvisioningLoadingState`, centred with a label, only for a screen with
//    nothing at all to show and no rows to stand in for — a modal wait like
//    "Ending the meeting…", a connect in progress.
//
// Never a bare spinner over a list: it says nothing about where the answer
// goes, and reads as detached from the content beneath it.

/// A blocking wait for a screen with nothing at all to show (rule 4 above).
/// A list waiting for its rows uses `EnvisioningPlaceholderRows` instead, and
/// an in-place refresh keeps its content and shows nothing.
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

/// Rows at a row's height while a list waits for its first answer — a cold
/// open with no snapshot. Put them inside the section whose rows they stand
/// for, under `if isLoading && rows.isEmpty`, so the list keeps its shape and
/// the answer lands in place. The bars are on the ladder (`border`), the same
/// row the Mac's Home draws while a module waits.
///
/// Laid out at once, so the height is stable, but drawn only after `delay`:
/// most answers land inside it, and a placeholder that flashes for 80 ms
/// reads as a flicker, not a wait. Hidden from assistive technology — a row
/// of bars says nothing; the screen's own title and the answer do the talking.
public struct EnvisioningPlaceholderRows: View {
    private let count: Int
    private let delay: Duration

    public init(count: Int = 3, delay: Duration = .milliseconds(250)) {
        self.count = count
        self.delay = delay
    }

    public var body: some View {
        ForEach(0..<count, id: \.self) { index in
            EnvisioningPlaceholderRow(delay: delay, variant: index)
        }
    }
}

/// One placeholder row: a glyph, a title bar, a detail bar. Widths step by
/// `variant` so a stack of them reads as rows, not as a repeated tile.
public struct EnvisioningPlaceholderRow: View {
    private let delay: Duration
    private let variant: Int
    @State private var visible = false

    public init(delay: Duration = .milliseconds(250), variant: Int = 0) {
        self.delay = delay
        self.variant = variant
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 10) {
            bar(width: 16, height: 16)
            VStack(alignment: .leading, spacing: 6) {
                bar(width: [140, 110, 170][variant % 3], height: 12)
                bar(width: [220, 190, 160][variant % 3], height: 10)
            }
        }
        .padding(.vertical, 3)
        .opacity(visible ? 1 : 0)
        .accessibilityHidden(true)
        .task {
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }
            withAnimation(.easeIn(duration: 0.18)) { visible = true }
        }
    }

    private func bar(width: CGFloat, height: CGFloat) -> some View {
        Capsule()
            .fill(EnvisioningSurface.border)
            .frame(maxWidth: width, alignment: .leading)
            .frame(height: height)
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
