import XCTest
import Vision
@testable import HandwritingApp

final class TextRecognitionConfigurationTests: XCTestCase {
    func testStandardConfiguration() {
        let config = TextRecognitionConfiguration.standard
        
        XCTAssertEqual(config.recognitionLevel, .accurate)
        XCTAssertTrue(config.usesLanguageCorrection)
        XCTAssertEqual(config.recognitionLanguages, ["en-US"])
        XCTAssertEqual(config.minimumTextHeight, 0.1)
        XCTAssertNil(config.customWords)
    }
    
    func testFastConfiguration() {
        let config = TextRecognitionConfiguration.fast
        
        XCTAssertEqual(config.recognitionLevel, .fast)
        XCTAssertFalse(config.usesLanguageCorrection)
        XCTAssertEqual(config.recognitionLanguages, ["en-US"])
        XCTAssertEqual(config.minimumTextHeight, 0.1)
        XCTAssertNil(config.customWords)
    }
    
    func testCustomConfiguration() {
        let customWords = ["test", "custom", "words"]
        let config = TextRecognitionConfiguration(
            recognitionLevel: .accurate,
            usesLanguageCorrection: true,
            recognitionLanguages: ["en-US", "fr-FR"],
            minimumTextHeight: 0.2,
            customWords: customWords
        )
        
        XCTAssertEqual(config.recognitionLevel, .accurate)
        XCTAssertTrue(config.usesLanguageCorrection)
        XCTAssertEqual(config.recognitionLanguages, ["en-US", "fr-FR"])
        XCTAssertEqual(config.minimumTextHeight, 0.2)
        XCTAssertEqual(config.customWords, customWords)
    }
    
    func testConfigurationWithoutCustomWords() {
        let config = TextRecognitionConfiguration(
            recognitionLevel: .fast,
            usesLanguageCorrection: false,
            recognitionLanguages: ["en-US"],
            minimumTextHeight: 0.15
        )
        
        XCTAssertEqual(config.recognitionLevel, .fast)
        XCTAssertFalse(config.usesLanguageCorrection)
        XCTAssertEqual(config.recognitionLanguages, ["en-US"])
        XCTAssertEqual(config.minimumTextHeight, 0.15)
        XCTAssertNil(config.customWords)
    }
}
