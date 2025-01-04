import Vision

/// Configuration settings for text recognition
struct TextRecognitionConfiguration {
    /// The level of recognition accuracy to use
    let recognitionLevel: VNRequestTextRecognitionLevel
    
    /// Whether to apply language correction to the recognized text
    let usesLanguageCorrection: Bool
    
    /// The languages to use for recognition
    let recognitionLanguages: [String]
    
    /// The minimum height of text to recognize as a fraction of image height
    let minimumTextHeight: Float
    
    /// Optional custom words to improve recognition accuracy
    let customWords: [String]?
    
    /// Standard configuration optimized for English handwriting
    static let standard = TextRecognitionConfiguration(
        recognitionLevel: .accurate,
        usesLanguageCorrection: true,
        recognitionLanguages: ["en-US"],
        minimumTextHeight: 0.05,  // Lower threshold to catch smaller text
        customWords: [
            // Common test words
            "test", "hello", "world",
            // Common English words that might be confused
            "the", "and", "that", "have", "for",
            "not", "with", "you", "this", "but",
            "his", "from", "they", "say", "her",
            "she", "will", "one", "all", "would",
            "there", "their", "what", "out", "about",
            "who", "get", "which", "when", "make",
            "can", "like", "time", "just", "him",
            "know", "take", "people", "into", "year",
            "your", "good", "some", "could", "them"
        ]
    )
    
    /// Configuration optimized for quick recognition
    static let fast = TextRecognitionConfiguration(
        recognitionLevel: .fast,
        usesLanguageCorrection: true,  // Enable correction even in fast mode
        recognitionLanguages: ["en-US"],
        minimumTextHeight: 0.05,  // Lower threshold to catch smaller text
        customWords: [
            // Common test words
            "test", "hello", "world"
        ]
    )
    
    /// Creates a new text recognition configuration
    /// - Parameters:
    ///   - recognitionLevel: The level of recognition accuracy to use
    ///   - usesLanguageCorrection: Whether to apply language correction
    ///   - recognitionLanguages: The languages to use for recognition
    ///   - minimumTextHeight: The minimum height of text to recognize
    ///   - customWords: Optional custom words to improve recognition
    init(
        recognitionLevel: VNRequestTextRecognitionLevel,
        usesLanguageCorrection: Bool,
        recognitionLanguages: [String],
        minimumTextHeight: Float,
        customWords: [String]? = nil
    ) {
        self.recognitionLevel = recognitionLevel
        self.usesLanguageCorrection = usesLanguageCorrection
        self.recognitionLanguages = recognitionLanguages
        self.minimumTextHeight = minimumTextHeight
        self.customWords = customWords
    }
}
