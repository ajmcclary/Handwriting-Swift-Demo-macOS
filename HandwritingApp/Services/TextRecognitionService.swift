import Vision
import CoreML
import AppKit
import SwiftUI

/// Service responsible for handling text recognition operations
actor TextRecognitionService {
    /// The ML model used for text recognition
    private let mlModel: MLModel?
    
    /// Creates a new instance of the text recognition service
    init() throws {
        // Try to find the compiled model
        let possiblePaths = [
            Bundle.main.resourcePath,
            Bundle.main.bundlePath,
            FileManager.default.currentDirectoryPath + "/.build/arm64-apple-macosx/debug",
            FileManager.default.currentDirectoryPath + "/HandwritingApp/Resources"
        ]
        
        for path in possiblePaths {
            if let path = path {
                let modelPath = path + "/TrOCR-Handwritten.mlmodelc"
                if FileManager.default.fileExists(atPath: modelPath) {
                    mlModel = try MLModel(contentsOf: URL(fileURLWithPath: modelPath))
                    return
                }
            }
        }
        
        throw HandwritingError.modelNotFound
    }
    
    /// Processes an image for text recognition
    /// - Parameters:
    ///   - view: The view to capture
    ///   - selectedArea: The area to process for text recognition
    /// - Returns: The recognized text
    /// - Throws: HandwritingError if processing fails
    func recognizeText(from view: some View, in selectedArea: CGRect) async throws -> String {
        // Create a bitmap representation of the view on the main actor
        let nsImage = try await MainActor.run {
            let renderer = ImageRenderer(content: view.frame(width: 800, height: 600))
            renderer.scale = 2.0
            
            guard let nsImage = renderer.nsImage else {
                throw HandwritingError.imageCreationFailed
            }
            return nsImage
        }
        
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
            throw HandwritingError.cgImageCreationFailed
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: HandwritingError.textRecognitionFailed(error))
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation],
                      !observations.isEmpty else {
                    continuation.resume(throwing: HandwritingError.noTextFound)
                    return
                }
                
                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                guard !recognizedStrings.isEmpty else {
                    continuation.resume(throwing: HandwritingError.noTextFound)
                    return
                }
                
                continuation.resume(returning: recognizedStrings.joined(separator: " "))
            }
            
            // Configure the request for handwriting
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["en-US"]
            
            do {
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: HandwritingError.textRecognitionFailed(error))
            }
        }
    }
}
