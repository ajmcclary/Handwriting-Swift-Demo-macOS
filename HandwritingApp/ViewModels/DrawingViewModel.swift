import SwiftUI
import AppKit
import SwiftUI

/// Manages the drawing state and coordinates with services for text recognition
/// 
/// The DrawingViewModel serves as the central coordinator for the application's drawing functionality.
/// It manages the current drawing state, handles user interactions, and coordinates with the
/// TextRecognitionService for processing handwritten text.
///
/// Key responsibilities:
/// - Managing drawing tools and current selection
/// - Coordinating drawing operations
/// - Handling text recognition through TextRecognitionService
/// - Managing error states and user feedback
@MainActor
class DrawingViewModel: ObservableObject {
    /// Current drawing tool selected by the user
    @Published var selectedTool: DrawingTool = .pencil
    
    /// Collection of all drawing lines
    @Published var lines: [DrawingLine] = []
    
    /// Current line being drawn
    @Published var currentLine: DrawingLine?
    
    /// Current lasso selection
    @Published var currentSelection: LassoSelection?
    
    /// Selected area for text recognition
    @Published var selectedArea: CGRect?
    
    /// Recognized text from the selected area
    @Published var recognizedText: String? {
        didSet {
            if let text = recognizedText {
                print("\n=== Recognized Text ===")
                print(text)
                print("=====================\n")
            }
        }
    }
    
    /// Error message to display
    @Published var errorMessage: String? {
        didSet {
            if let error = errorMessage {
                print("\n=== Error ===")
                print(error)
                print("============\n")
            }
        }
    }
    
    /// Loading state for ML processing
    @Published var isProcessing = false
    
    /// Service responsible for text recognition
    private let textRecognitionService: TextRecognitionService
    
    init() {
        do {
            textRecognitionService = try TextRecognitionService()
        } catch {
            textRecognitionService = try! TextRecognitionService() // Force-try as fallback for preview
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
    
    /// Start a new line at the given point
    func startDrawing(at point: CGPoint, pressure: CGFloat = 1.0) {
        switch selectedTool {
        case .pencil:
            currentLine = DrawingLine(
                points: [DrawingPoint(x: point.x, y: point.y, pressure: pressure)],
                color: .black,
                lineWidth: 2.0
            )
        case .eraser:
            currentLine = DrawingLine(
                points: [DrawingPoint(x: point.x, y: point.y, pressure: pressure)],
                color: .white,
                lineWidth: 20.0
            )
        case .lasso:
            currentSelection = LassoSelection(points: [DrawingPoint(x: point.x, y: point.y, pressure: pressure)])
        }
    }
    
    /// Add a point to the current line
    func addPoint(_ point: CGPoint, pressure: CGFloat = 1.0) {
        let drawingPoint = DrawingPoint(x: point.x, y: point.y, pressure: pressure)
        
        switch selectedTool {
        case .pencil, .eraser:
            currentLine?.points.append(drawingPoint)
        case .lasso:
            currentSelection?.points.append(drawingPoint)
        }
    }
    
    /// End the current drawing action
    func endDrawing() {
        switch selectedTool {
        case .pencil, .eraser:
            if let line = currentLine {
                lines.append(line)
                currentLine = nil
            }
        case .lasso:
            if var selection = currentSelection {
                selection.updateBoundingBox()
                currentSelection = selection
                if let boundingBox = selection.boundingBox {
                    selectedArea = boundingBox
                }
            }
        }
    }
    
    /// Process the selected area for text recognition
    /// - Returns: The recognized text if successful
    func processSelectedArea() async {
        guard let selectedArea = selectedArea else { return }
        
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            let view = DrawingCanvasView(viewModel: self)
                .frame(width: 800, height: 600)
                .background(Color.white)
            
            do {
                recognizedText = try await textRecognitionService.recognizeText(
                    from: view,
                    in: selectedArea
                )
            } catch {
                throw error
            }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
    
    /// Clear the current selection
    func clearSelection() {
        currentSelection = nil
        selectedArea = nil
        recognizedText = nil
    }
    
    /// Clear all drawings
    func clearCanvas() {
        lines.removeAll()
        clearSelection()
    }
}
