import SwiftUI
import UIKit

// ──────────────────────────────────────────────────────────────────
// CodeViewerView
// Scrollable, syntax-highlighted Swift source viewer built on
// UITextView so we get smooth scrolling and text selection for free.
// ──────────────────────────────────────────────────────────────────
struct CodeViewerView: View {
    let code: String
    let filename: String
    let layerColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // File tab header
            HStack(spacing: 8) {
                Image(systemName: "doc.fill")
                    .foregroundStyle(layerColor)
                Text(filename)
                    .font(.caption.bold())
                    .foregroundStyle(layerColor)
                Spacer()
                Text("Swift")
                    .font(.caption2)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Color.orange.opacity(0.15))
                    .foregroundStyle(.orange)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(layerColor.opacity(0.08))

            Divider()

            // Code content
            HighlightedCodeView(code: code)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(layerColor.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - UITextView Wrapper

private struct HighlightedCodeView: UIViewRepresentable {
    let code: String

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.isEditable = false
        tv.isSelectable = true
        tv.backgroundColor = UIColor.systemBackground
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        tv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = SyntaxHighlighter.highlight(code)
    }
}

// MARK: - Multi-File Tab Viewer

struct TabbedCodeViewer: View {
    let files: [CodeFile]
    @State private var selectedFileIndex = 0

    var body: some View {
        VStack(spacing: 0) {
            // File tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(files.enumerated()), id: \.offset) { idx, file in
                        Button {
                            selectedFileIndex = idx
                        } label: {
                            VStack(spacing: 2) {
                                Text(file.filename)
                                    .font(.caption.bold())
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .foregroundStyle(selectedFileIndex == idx ? file.layerColor : .secondary)
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundStyle(selectedFileIndex == idx ? file.layerColor : Color.clear)
                            }
                        }
                    }
                }
            }
            .background(Color(.systemGray6))

            Divider()

            if files.indices.contains(selectedFileIndex) {
                let file = files[selectedFileIndex]
                VStack(alignment: .leading, spacing: 6) {
                    // Layer badge
                    HStack {
                        Text(file.layerName)
                            .font(.caption2)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(file.layerColor.opacity(0.15))
                            .foregroundStyle(file.layerColor)
                            .clipShape(Capsule())
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 8)

                    HighlightedCodeView(code: file.code)
                }
            }
        }
    }
}
