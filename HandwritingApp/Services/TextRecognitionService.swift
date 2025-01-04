import Vision
import AppKit
import SwiftUI

/// Service responsible for handling text recognition operations using Vision framework
actor TextRecognitionService {
    /// Configuration for text recognition
    private let configuration: TextRecognitionConfiguration
    
    /// Creates a new instance of the text recognition service
    /// - Parameter configuration: Configuration for text recognition, defaults to standard English
    /// - Throws: HandwritingError if initialization fails
    init(configuration: TextRecognitionConfiguration = .standard) throws {
        self.configuration = configuration
        
        // Validate Vision availability
        guard VNRecognizeTextRequestRevision1 <= VNRecognizeTextRequest.currentRevision else {
            throw HandwritingError.textRecognitionUnavailable
        }
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
            renderer.scale = 4.0  // Higher scale for better resolution
            
            guard let nsImage = renderer.nsImage else {
                throw HandwritingError.imageCreationFailed
            }
            return nsImage
        }
        
        // Create a new image for the cropped area with preprocessing
        let croppedImage = NSImage(size: selectedArea.size)
        croppedImage.lockFocus()
        
        // Set up graphics context for preprocessing
        if let context = NSGraphicsContext.current?.cgContext {
            // Draw white background first
            context.setFillColor(NSColor.white.cgColor)
            context.fill(CGRect(origin: .zero, size: selectedArea.size))
            
            // Draw the portion of the original image with contrast adjustment
            let sourceRect = NSRect(
                x: selectedArea.origin.x,
                y: nsImage.size.height - selectedArea.origin.y - selectedArea.height,
                width: selectedArea.width,
                height: selectedArea.height
            )
            
            let destRect = NSRect(origin: .zero, size: selectedArea.size)
            
            // Apply contrast enhancement
            context.setShadow(offset: .zero, blur: 0, color: nil)
            context.setBlendMode(.normal)
            
            nsImage.draw(in: destRect, from: sourceRect, operation: .sourceOver, fraction: 1.2)  // Slightly increase contrast
        }
        
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
            
            configureTextRequest(request, with: configuration)
            
            do {
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: HandwritingError.textRecognitionFailed(error))
            }
        }
    }
    
    /// Configures a VNRecognizeTextRequest with the specified settings
    /// - Parameters:
    ///   - request: The request to configure
    ///   - configuration: The configuration to apply
    private func configureTextRequest(
        _ request: VNRecognizeTextRequest,
        with configuration: TextRecognitionConfiguration
    ) {
            // Configure base settings
            request.recognitionLevel = configuration.recognitionLevel
            request.usesLanguageCorrection = configuration.usesLanguageCorrection
            request.recognitionLanguages = configuration.recognitionLanguages
            request.minimumTextHeight = configuration.minimumTextHeight
            
            // Add custom words if available
            if let customWords = configuration.customWords {
                request.customWords = customWords
            }
            
            // Additional recognition settings
            request.revision = VNRecognizeTextRequestRevision2  // Use latest revision
            request.usesCPUOnly = false  // Allow Neural Engine usage
            request.recognitionLanguages = ["en-US", "en-GB"]  // Support multiple English variants
    }
}
