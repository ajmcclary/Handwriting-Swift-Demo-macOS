import Foundation

/// Represents errors that can occur in the Handwriting application
///
/// This enum provides detailed error information and recovery suggestions for various
/// failure scenarios in the handwriting recognition process.
enum HandwritingError: LocalizedError {
    /// Failed to create an image from the view selection
    case imageCreationFailed
    
    /// Failed to create a CGImage from the NSImage
    case cgImageCreationFailed
    
    /// Text recognition process failed with an underlying error
    case textRecognitionFailed(Error)
    
    /// No text was found in the processed image
    case noTextFound
    
    /// Text recognition is not available on this device
    case textRecognitionUnavailable
    
    var errorDescription: String? {
        switch self {
        case .imageCreationFailed:
            return "Failed to capture the selected area"
        case .cgImageCreationFailed:
            return "Failed to process the selected area"
        case .textRecognitionFailed(let error):
            return "Text recognition failed: \(error.localizedDescription)"
        case .noTextFound:
            return "No text was found in the selected area"
        case .textRecognitionUnavailable:
            return "Text recognition is not available on this device"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .imageCreationFailed:
            return "Try selecting a different area or reducing the selection size"
        case .cgImageCreationFailed:
            return "Try selecting a smaller area or ensuring the selection contains visible content"
        case .textRecognitionFailed:
            return "Try writing more clearly, using darker strokes, or selecting a different area"
        case .noTextFound:
            return "Ensure your handwriting is clear and contained within the selected area"
        case .textRecognitionUnavailable:
            return "This feature requires macOS 10.15 or later with supported hardware"
        }
    }
    
    var helpAnchor: String? {
        switch self {
        case .imageCreationFailed:
            return "selection-guide"
        case .cgImageCreationFailed:
            return "image-processing-guide"
        case .textRecognitionFailed:
            return "recognition-troubleshooting"
        case .noTextFound:
            return "handwriting-tips"
        case .textRecognitionUnavailable:
            return "system-requirements"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .imageCreationFailed:
            return "The application was unable to create an image from the selected area"
        case .cgImageCreationFailed:
            return "The selected area could not be processed for text recognition"
        case .textRecognitionFailed(let error):
            return "The text recognition system encountered an error: \(error.localizedDescription)"
        case .noTextFound:
            return "The text recognition system could not identify any text in the image"
        case .textRecognitionUnavailable:
            return "The required text recognition capabilities are not available on this system"
        }
    }
}
