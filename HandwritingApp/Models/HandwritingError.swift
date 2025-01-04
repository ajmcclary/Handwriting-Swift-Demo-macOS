import Foundation

/// Represents errors that can occur in the Handwriting application
enum HandwritingError: LocalizedError {
    case imageCreationFailed
    case cgImageCreationFailed
    case textRecognitionFailed(Error)
    case noTextFound
    
    var errorDescription: String? {
        switch self {
        case .imageCreationFailed:
            return "Failed to create image from selection"
        case .cgImageCreationFailed:
            return "Failed to process selected area"
        case .textRecognitionFailed(let error):
            return "Text recognition failed: \(error.localizedDescription)"
        case .noTextFound:
            return "No text was found in the selected area"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .imageCreationFailed:
            return "Try selecting a different area"
        case .cgImageCreationFailed:
            return "Try selecting a smaller area"
        case .textRecognitionFailed:
            return "Try writing more clearly or selecting a different area"
        case .noTextFound:
            return "Try writing more clearly or selecting text only"
        }
    }
}
