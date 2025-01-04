import SwiftUI
import CoreML
import Vision
import AppKit
import CoreImage

/// Manages the drawing state and ML processing for the application
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
    
    private var mlModel: MLModel?
    private let ciContext = CIContext()
    
    init() {
        do {
            // Try to find the compiled model
            let possiblePaths = [
                Bundle.main.resourcePath,
                Bundle.main.bundlePath,
                FileManager.default.currentDirectoryPath + "/.build/arm64-apple-macosx/debug",
                FileManager.default.currentDirectoryPath + "/HandwritingApp/Resources"
            ]
            
            var modelFound = false
            for path in possiblePaths {
                if let path = path {
                    let modelPath = path + "/TrOCR-Handwritten.mlmodelc"
                    print("Checking path: \(modelPath)")
                    if FileManager.default.fileExists(atPath: modelPath) {
                        mlModel = try MLModel(contentsOf: URL(fileURLWithPath: modelPath))
                        print("Found and loaded model at: \(modelPath)")
                        modelFound = true
                        break
                    }
                }
            }
            
            if !modelFound {
                errorMessage = "Failed to locate ML model"
            }
        } catch {
            errorMessage = "Failed to load ML model: \(error.localizedDescription)"
            print("Error loading model: \(error)")
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
    func processSelectedArea() async {
        guard let selectedArea = selectedArea else {
            print("No selected area")
            return
        }
        
        print("\nProcessing selected area: \(selectedArea)")
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            // Create a bitmap representation of the entire view
            let view = DrawingCanvasView(viewModel: self)
                .frame(width: 800, height: 600)
            
            let renderer = ImageRenderer(content: view)
            renderer.scale = 2.0
            
            print("Creating image from view...")
            guard let nsImage = renderer.nsImage else {
                errorMessage = "Failed to create image from selection"
                return
            }
            
            print("Image size: \(nsImage.size)")
            
            // Create a new image for the cropped area
            let croppedImage = NSImage(size: selectedArea.size)
            croppedImage.lockFocus()
            
            // Draw the portion of the original image into the new image
            let sourceRect = NSRect(
                x: selectedArea.origin.x,
                y: nsImage.size.height - selectedArea.origin.y - selectedArea.height,
                width: selectedArea.width,
                height: selectedArea.height
            )
            
            let destRect = NSRect(origin: .zero, size: selectedArea.size)
            nsImage.draw(in: destRect, from: sourceRect, operation: .copy, fraction: 1.0)
            
            croppedImage.unlockFocus()
            
            // Convert NSImage to CGImage
            guard let cgImage = croppedImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                errorMessage = "Failed to create CGImage"
                return
            }
            
            print("Creating Vision request...")
            let request = VNRecognizeTextRequest { [weak self] request, error in
                if let error = error {
                    self?.errorMessage = "Recognition failed: \(error.localizedDescription)"
                    print("Recognition error details: \(error)")
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    print("No text observations found")
                    return
                }
                
                print("Found \(observations.count) text observations")
                observations.forEach { observation in
                    print("Observation confidence: \(observation.confidence)")
                    if let candidate = observation.topCandidates(1).first {
                        print("Candidate text: \(candidate.string), confidence: \(candidate.confidence)")
                    }
                }
                
                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                if recognizedStrings.isEmpty {
                    print("No text candidates found in observations")
                }
                
                self?.recognizedText = recognizedStrings.joined(separator: " ")
            }
            
            // Configure the request for handwriting
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["en-US"]
            
            print("Performing Vision request...")
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try handler.perform([request])
            
        } catch {
            errorMessage = "Failed to process image: \(error.localizedDescription)"
            print("Error details: \(error)")
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
