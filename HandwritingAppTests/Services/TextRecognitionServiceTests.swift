import XCTest
import Vision
import CoreML
@testable import HandwritingApp

final class TextRecognitionServiceTests: XCTestCase {
    var service: TextRecognitionService!
    
    override func setUp() {
        super.setUp()
        do {
            service = try TextRecognitionService()
        } catch {
            XCTFail("Failed to initialize TextRecognitionService: \(error)")
        }
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertNotNil(service, "TextRecognitionService should initialize successfully")
    }
    
    // MARK: - Error Handling Tests
    
    func testRecognizeTextWithInvalidView() async {
        let invalidView = DrawingCanvasView(viewModel: DrawingViewModel())
        let emptyArea = CGRect(x: 0, y: 0, width: 0, height: 0)
        
        do {
            _ = try await service.recognizeText(from: invalidView, in: emptyArea)
            XCTFail("Should throw an error for invalid view")
        } catch let error as HandwritingError {
            XCTAssertEqual(error, HandwritingError.imageCreationFailed)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testRecognizeTextWithInvalidArea() async {
        let view = DrawingCanvasView(viewModel: DrawingViewModel())
        let invalidArea = CGRect(x: -100, y: -100, width: 0, height: 0)
        
        do {
            _ = try await service.recognizeText(from: view, in: invalidArea)
            XCTFail("Should throw an error for invalid area")
        } catch let error as HandwritingError {
            XCTAssertEqual(error, HandwritingError.imageCreationFailed)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Integration Tests
    
    func testRecognizeTextWithValidInput() async {
        // Create a view model with some test drawing
        let viewModel = DrawingViewModel()
        viewModel.selectedTool = .pencil
        
        // Simulate drawing a simple line
        let points = [
            CGPoint(x: 100, y: 100),
            CGPoint(x: 200, y: 100)
        ]
        
        viewModel.startDrawing(at: points[0])
        viewModel.addPoint(points[1])
        viewModel.endDrawing()
        
        let view = DrawingCanvasView(viewModel: viewModel)
        let area = CGRect(x: 50, y: 50, width: 200, height: 100)
        
        do {
            _ = try await service.recognizeText(from: view, in: area)
            // Note: We can't assert specific text results since we don't have a real ML model in tests
            // Instead, we just verify that the call completes without throwing an error
        } catch {
            XCTFail("Text recognition should not fail with valid input: \(error)")
        }
    }
    
    // MARK: - Performance Tests
    
    func testRecognizeTextPerformance() async {
        let viewModel = DrawingViewModel()
        let view = DrawingCanvasView(viewModel: viewModel)
        let area = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        measure {
            Task {
                do {
                    _ = try await service.recognizeText(from: view, in: area)
                } catch {
                    // Ignore errors in performance test
                }
            }
        }
    }
}

// MARK: - Test Helpers

extension HandwritingError: Equatable {
    public static func == (lhs: HandwritingError, rhs: HandwritingError) -> Bool {
        switch (lhs, rhs) {
        case (.modelNotFound, .modelNotFound):
            return true
        case (.modelLoadFailed(let error1), .modelLoadFailed(let error2)):
            return error1.localizedDescription == error2.localizedDescription
        case (.imageCreationFailed, .imageCreationFailed):
            return true
        case (.cgImageCreationFailed, .cgImageCreationFailed):
            return true
        case (.textRecognitionFailed(let error1), .textRecognitionFailed(let error2)):
            return error1.localizedDescription == error2.localizedDescription
        case (.noTextFound, .noTextFound):
            return true
        default:
            return false
        }
    }
}
