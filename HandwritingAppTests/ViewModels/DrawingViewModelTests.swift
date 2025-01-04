import XCTest
import Vision
import SwiftUI
@testable import HandwritingApp

final class DrawingViewModelTests: XCTestCase {
    func testInitializationSuccess() async throws {
        let viewModel = try DrawingViewModel()
        
        XCTAssertEqual(viewModel.selectedTool, .pencil)
        XCTAssertTrue(viewModel.lines.isEmpty)
        XCTAssertNil(viewModel.currentLine)
        XCTAssertNil(viewModel.currentSelection)
        XCTAssertNil(viewModel.selectedArea)
        XCTAssertNil(viewModel.recognizedText)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isProcessing)
    }
    
    func testInitializationWithCustomService() async throws {
        let service = try TextRecognitionService(configuration: .fast)
        let viewModel = try DrawingViewModel(textRecognitionService: service)
        
        XCTAssertNotNil(viewModel)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testProcessSelectedAreaWithNoSelection() async throws {
        let viewModel = try DrawingViewModel()
        
        await viewModel.processSelectedArea()
        
        XCTAssertEqual(viewModel.errorMessage, "No area selected for text recognition")
        XCTAssertNil(viewModel.recognizedText)
        XCTAssertFalse(viewModel.isProcessing)
    }
    
    func testProcessSelectedAreaWithNoDrawing() async throws {
        let viewModel = try DrawingViewModel()
        viewModel.selectedArea = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        await viewModel.processSelectedArea()
        
        XCTAssertEqual(viewModel.errorMessage, "No drawing content to process")
        XCTAssertNil(viewModel.recognizedText)
        XCTAssertFalse(viewModel.isProcessing)
    }
    
    func testClearSelection() async throws {
        let viewModel = try DrawingViewModel()
        
        // Set up some selection state
        viewModel.currentSelection = LassoSelection(points: [
            DrawingPoint(x: 0, y: 0, pressure: 1.0)
        ])
        viewModel.selectedArea = CGRect(x: 0, y: 0, width: 100, height: 100)
        viewModel.recognizedText = "Test text"
        
        // Clear the selection
        viewModel.clearSelection()
        
        // Verify everything is cleared
        XCTAssertNil(viewModel.currentSelection)
        XCTAssertNil(viewModel.selectedArea)
        XCTAssertNil(viewModel.recognizedText)
    }
    
    func testClearCanvas() async throws {
        let viewModel = try DrawingViewModel()
        
        // Add some drawing content
        viewModel.lines = [
            DrawingLine(
                points: [DrawingPoint(x: 0, y: 0, pressure: 1.0)],
                color: .black,
                lineWidth: 2.0
            )
        ]
        viewModel.selectedArea = CGRect(x: 0, y: 0, width: 100, height: 100)
        viewModel.recognizedText = "Test text"
        
        // Clear the canvas
        viewModel.clearCanvas()
        
        // Verify everything is cleared
        XCTAssertTrue(viewModel.lines.isEmpty)
        XCTAssertNil(viewModel.selectedArea)
        XCTAssertNil(viewModel.recognizedText)
    }
    
    func testDrawingToolSelection() async throws {
        let viewModel = try DrawingViewModel()
        
        // Test pencil tool
        viewModel.selectedTool = .pencil
        viewModel.startDrawing(at: CGPoint(x: 0, y: 0))
        XCTAssertEqual(viewModel.currentLine?.color, .black)
        XCTAssertEqual(viewModel.currentLine?.lineWidth, 2.0)
        
        // Test eraser tool
        viewModel.selectedTool = .eraser
        viewModel.startDrawing(at: CGPoint(x: 0, y: 0))
        XCTAssertEqual(viewModel.currentLine?.color, .white)
        XCTAssertEqual(viewModel.currentLine?.lineWidth, 20.0)
        
        // Test lasso tool
        viewModel.selectedTool = .lasso
        viewModel.startDrawing(at: CGPoint(x: 0, y: 0))
        XCTAssertNotNil(viewModel.currentSelection)
        XCTAssertNil(viewModel.currentLine)
    }
    
    func testAddPointToLine() async throws {
        let viewModel = try DrawingViewModel()
        let startPoint = CGPoint(x: 0, y: 0)
        let newPoint = CGPoint(x: 10, y: 10)
        
        // Start drawing
        viewModel.startDrawing(at: startPoint)
        XCTAssertEqual(viewModel.currentLine?.points.count, 1)
        
        // Add a point
        viewModel.addPoint(newPoint)
        XCTAssertEqual(viewModel.currentLine?.points.count, 2)
        XCTAssertEqual(viewModel.currentLine?.points.last?.x, 10)
        XCTAssertEqual(viewModel.currentLine?.points.last?.y, 10)
    }
    
    func testEndDrawing() async throws {
        let viewModel = try DrawingViewModel()
        
        // Test ending pencil drawing
        viewModel.selectedTool = .pencil
        viewModel.startDrawing(at: CGPoint(x: 0, y: 0))
        viewModel.endDrawing()
        XCTAssertEqual(viewModel.lines.count, 1)
        XCTAssertNil(viewModel.currentLine)
        
        // Test ending lasso selection
        viewModel.selectedTool = .lasso
        viewModel.startDrawing(at: CGPoint(x: 0, y: 0))
        viewModel.addPoint(CGPoint(x: 100, y: 0))
        viewModel.addPoint(CGPoint(x: 100, y: 100))
        viewModel.addPoint(CGPoint(x: 0, y: 100))
        viewModel.endDrawing()
        XCTAssertNotNil(viewModel.selectedArea)
    }
}
