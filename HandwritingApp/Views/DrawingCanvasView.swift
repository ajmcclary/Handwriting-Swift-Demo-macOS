import SwiftUI

/// A canvas view that provides drawing and selection functionality
///
/// DrawingCanvasView is responsible for:
/// - Handling drawing input from the user
/// - Rendering the current drawing state
/// - Managing the lasso selection tool
/// - Providing visual feedback for the current tool
///
/// The view uses SwiftUI's Canvas API for high-performance drawing and
/// supports pressure sensitivity when available.
struct DrawingCanvasView: View {
    /// View model that manages the drawing state
    @ObservedObject var viewModel: DrawingViewModel
    
    /// Tracks whether the user is currently drawing or selecting
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                // Set up canvas for accessibility
                context.withCGContext { cgContext in
                    cgContext.setAllowsAntialiasing(true)
                    cgContext.setLineCap(.round)
                    cgContext.setLineJoin(.round)
                }
                
                // Draw existing lines
                for line in viewModel.lines {
                    var path = Path()
                    guard let firstPoint = line.points.first else { continue }
                    
                    path.move(to: CGPoint(x: firstPoint.x, y: firstPoint.y))
                    
                    for point in line.points.dropFirst() {
                        path.addLine(to: CGPoint(x: point.x, y: point.y))
                    }
                    
                    context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
                }
                
                // Draw current line
                if let currentLine = viewModel.currentLine {
                    var path = Path()
                    guard let firstPoint = currentLine.points.first else { return }
                    
                    path.move(to: CGPoint(x: firstPoint.x, y: firstPoint.y))
                    
                    for point in currentLine.points.dropFirst() {
                        path.addLine(to: CGPoint(x: point.x, y: point.y))
                    }
                    
                    context.stroke(path, with: .color(currentLine.color), lineWidth: currentLine.lineWidth)
                }
                
                // Draw lasso selection
                if let selection = viewModel.currentSelection {
                    var path = Path()
                    guard let firstPoint = selection.points.first else { return }
                    
                    path.move(to: CGPoint(x: firstPoint.x, y: firstPoint.y))
                    
                    for point in selection.points.dropFirst() {
                        path.addLine(to: CGPoint(x: point.x, y: point.y))
                    }
                    
                    if selection.points.count > 2 {
                        path.addLine(to: CGPoint(x: firstPoint.x, y: firstPoint.y))
                    }
                    
                    context.stroke(path, with: .color(.blue.opacity(0.5)), lineWidth: 2)
                }
                
                // Draw selected area
                if let selectedArea = viewModel.selectedArea {
                    let selectionPath = Path(roundedRect: selectedArea, cornerRadius: 0)
                    context.stroke(selectionPath, with: .color(.blue), lineWidth: 2)
                    context.fill(selectionPath, with: .color(.blue.opacity(0.1)))
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            viewModel.startDrawing(at: value.location)
                        } else {
                            viewModel.addPoint(value.location)
                        }
                    }
                    .onEnded { _ in
                        isDragging = false
                        viewModel.endDrawing()
                    }
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Drawing Canvas")
            .accessibilityAddTraits(.allowsDirectInteraction)
            .accessibilityHint("Draw with selected tool by dragging on the canvas")
            .onHover { hovering in
                if hovering {
                    let cursor: NSCursor = {
                        switch viewModel.selectedTool {
                        case .pencil:
                            return NSCursor.crosshair
                        case .eraser:
                            return NSCursor.crosshair
                        case .lasso:
                            return NSCursor.crosshair
                        }
                    }()
                    cursor.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
        .background(Color.white)
        .accessibilityIdentifier("view.drawingCanvas")
        .overlay(
            Group {
                if viewModel.isProcessing {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        )
        .overlay(
            Group {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                        .padding()
                }
            }
        )
    }
}

#Preview {
    DrawingCanvasView(viewModel: DrawingViewModel.preview())
        .frame(width: 400, height: 400)
}
