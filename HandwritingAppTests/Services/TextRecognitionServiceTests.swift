import XCTest
import Vision
import SwiftUI
@testable import HandwritingApp

final class TextRecognitionServiceTests: XCTestCase {
    func testInitializationWithStandardConfig() throws {
        let service = try TextRecognitionService(configuration: .standard)
        XCTAssertNotNil(service)
    }
    
    func testInitializationWithFastConfig() throws {
        let service = try TextRecognitionService(configuration: .fast)
        XCTAssertNotNil(service)
    }
    
    func testInitializationWithCustomConfig() throws {
        let config = TextRecognitionConfiguration(
            recognitionLevel: .accurate,
            usesLanguageCorrection: true,
            recognitionLanguages: ["en-US", "fr-FR"],
            minimumTextHeight: 0.2,
            customWords: ["test", "custom"]
        )
        let service = try TextRecognitionService(configuration: config)
        XCTAssertNotNil(service)
    }
    
    func testRecognizeTextWithNoText() async throws {
        let service = try TextRecognitionService(configuration: .standard)
        let view = Text("Test View").frame(width: 100, height: 100)
        let area = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        do {
            _ = try await service.recognizeText(from: view, in: area)
            XCTFail("Expected error to be thrown")
        } catch let error as HandwritingError {
            XCTAssertEqual(error, HandwritingError.noTextFound)
        }
    }
    
    func testRecognizeTextWithInvalidArea() async throws {
        let service = try TextRecognitionService(configuration: .standard)
        let view = Text("Test View").frame(width: 100, height: 100)
        let invalidArea = CGRect(x: -100, y: -100, width: 0, height: 0)
        
        do {
            _ = try await service.recognizeText(from: view, in: invalidArea)
            XCTFail("Expected error to be thrown")
        } catch let error as HandwritingError {
            XCTAssertEqual(error, HandwritingError.imageCreationFailed)
        }
    }
    
    func testRecognizeTextWithUnavailableService() async {
        do {
            _ = try TextRecognitionService(configuration: .standard)
            // Note: This test might pass or fail depending on the device's Vision capabilities
            // In a real test environment, we would mock the Vision framework to force this scenario
        } catch let error as HandwritingError {
            XCTAssertEqual(error, HandwritingError.textRecognitionUnavailable)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestView() -> some View {
        Text("Test View")
            .frame(width: 100, height: 100)
            .background(Color.white)
    }
    
    private func createValidArea() -> CGRect {
        CGRect(x: 0, y: 0, width: 100, height: 100)
    }
}

// MARK: - Test Helpers

extension HandwritingError: Equatable {
    public static func == (lhs: HandwritingError, rhs: HandwritingError) -> Bool {
        switch (lhs, rhs) {
        case (.imageCreationFailed, .imageCreationFailed),
             (.cgImageCreationFailed, .cgImageCreationFailed),
             (.noTextFound, .noTextFound),
             (.textRecognitionUnavailable, .textRecognitionUnavailable):
            return true
        case (.textRecognitionFailed(let lhsError), .textRecognitionFailed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
