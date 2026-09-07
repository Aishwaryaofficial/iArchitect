import SwiftUI

// ──────────────────────────────────────────────────────────────────
// DiagramView — animated architecture layer diagrams
// Renders node boxes and directional arrows for each pattern.
// ──────────────────────────────────────────────────────────────────
struct DiagramView: View {
    let pattern: ArchPattern
    @State private var animate = false

    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            DiagramCanvas(pattern: pattern, animate: animate)
                .padding(24)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).delay(0.2)) {
                animate = true
            }
        }
    }
}

// MARK: - Canvas

private struct DiagramCanvas: View {
    let pattern: ArchPattern
    let animate: Bool

    // Fixed cell size for layout
    private let cellW: CGFloat = 120
    private let cellH: CGFloat = 64
    private let hSpacing: CGFloat = 40
    private let vSpacing: CGFloat = 50

    var body: some View {
        let (nodes, totalCols, totalRows) = layoutInfo()
        let canvasW = CGFloat(totalCols) * (cellW + hSpacing) - hSpacing
        let canvasH = CGFloat(totalRows) * (cellH + vSpacing) - vSpacing

        ZStack {
            // Draw edges first (behind nodes)
            ForEach(pattern.diagramEdges) { edge in
                if let fromNode = nodes[edge.fromNode],
                   let toNode   = nodes[edge.toNode] {
                    EdgeArrow(
                        from: nodeCenter(fromNode),
                        to:   nodeCenter(toNode),
                        label: edge.label,
                        color: .secondary,
                        isBidirectional: edge.isBidirectional,
                        animate: animate
                    )
                }
            }

            // Draw nodes
            ForEach(pattern.diagramNodes) { node in
                NodeBox(node: node, animate: animate)
                    .position(nodeCenter(node))
            }
        }
        .frame(width: canvasW, height: canvasH)
    }

    // Returns [nodeId: node] dict + grid dimensions
    private func layoutInfo() -> ([String: DiagramNode], Int, Int) {
        var dict: [String: DiagramNode] = [:]
        var maxCol = 0, maxRow = 0
        for n in pattern.diagramNodes {
            dict[n.id] = n
            maxCol = max(maxCol, n.col)
            maxRow = max(maxRow, n.row)
        }
        return (dict, maxCol + 1, maxRow + 1)
    }

    private func nodeCenter(_ node: DiagramNode) -> CGPoint {
        let x = CGFloat(node.col) * (cellW + hSpacing) + cellW / 2
        let y = CGFloat(node.row) * (cellH + vSpacing) + cellH / 2
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Node Box

private struct NodeBox: View {
    let node: DiagramNode
    let animate: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text(node.label)
                .font(.caption.bold())
                .foregroundStyle(node.color)
            Text(node.sublabel)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 110, height: 56)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(node.color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(node.color.opacity(0.6), lineWidth: 1.5)
        )
        .scaleEffect(animate ? 1 : 0.7)
        .opacity(animate ? 1 : 0)
    }
}

// MARK: - Edge Arrow

private struct EdgeArrow: View {
    let from: CGPoint
    let to: CGPoint
    let label: String
    let color: Color
    let isBidirectional: Bool
    let animate: Bool

    var body: some View {
        Canvas { context, _ in
            guard animate else { return }

            let arrowPath = Path { p in
                p.move(to: from)
                p.addLine(to: to)
            }

            context.stroke(arrowPath,
                           with: .color(color.opacity(0.5)),
                           style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))

            // Arrowhead at 'to'
            drawArrowHead(&context, at: to, toward: from, color: color.opacity(0.6))
            if isBidirectional {
                drawArrowHead(&context, at: from, toward: to, color: color.opacity(0.6))
            }
        }
        .overlay(
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(color.opacity(0.8))
                .position(midpoint)
                .opacity(animate ? 1 : 0)
        )
    }

    private var midpoint: CGPoint {
        CGPoint(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2)
    }

    private func drawArrowHead(_ context: inout GraphicsContext,
                                 at tip: CGPoint,
                                 toward: CGPoint,
                                 color: Color) {
        let angle = atan2(tip.y - toward.y, tip.x - toward.x)
        let len: CGFloat = 8
        let spread: CGFloat = 0.4

        let p1 = CGPoint(x: tip.x - len * cos(angle - spread),
                         y: tip.y - len * sin(angle - spread))
        let p2 = CGPoint(x: tip.x - len * cos(angle + spread),
                         y: tip.y - len * sin(angle + spread))

        var head = Path()
        head.move(to: tip)
        head.addLine(to: p1)
        head.addLine(to: p2)
        head.closeSubpath()
        context.fill(head, with: .color(color))
    }
}
