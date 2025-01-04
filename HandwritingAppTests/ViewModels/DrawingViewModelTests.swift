import XCTest
@testable import HandwritingApp

final class DrawingViewModelTests: XCTestCase {
    var viewModel: DrawingViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = DrawingViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Tool Selection Tests
    
    func testInitialToolIsPencil() {
        XCTAssertEqual(viewModel.selectedTool, .pencil)
    }
    
    func testToolSelection() {
        viewModel.selectedTool = .eraser
        XCTAssertEqual(viewModel.selectedTool, .eraser)
        
        viewModel.selectedTool = .lasso
        XCTAssertEqual(viewModel.selectedTool, .lasso)
    }
    
    // MARK: - Drawing Tests
    
    func testStartDrawingWithPencil() {
        viewModel.selectedTool = .pencil
        let point = CGPoint(x: 100, y: 100)
        
        viewModel.startDrawing(at: point)
        
        XCTAssertNotNil(viewModel.currentLine)
        XCTAssertEqual(viewModel.currentLine?.points.first?.x, point.x)
        XCTAssertEqual(viewModel.currentLine?.points.first?.y, point.y)
        XCTAssertEqual(viewModel.currentLine?.color, .black)
        XCTAssertEqual(viewModel.currentLine?.lineWidth, 2.0)
    }
    
    func testStartDrawingWithEraser() {
        viewModel.selectedTool = .eraser
        let point = CGPoint(x: 100, y: 100)
        
        viewModel.startDrawing(at: point)
        
        XCTAssertNotNil(viewModel.currentLine)
        XCTAssertEqual(viewModel.currentLine?.points.first?.x, point.x)
        XCTAssertEqual(viewModel.currentLine?.points.first?.y, point.y)
        XCTAssertEqual(viewModel.currentLine?.color, .white)
        XCTAssertEqual(viewModel.currentLine?.lineWidth, 20.0)
    }
    
    func testAddPoint() {
        viewModel.selectedTool = .pencil
        let startPoint = CGPoint(x: 100, y: 100)
        let newPoint = CGPoint(x: 150, y: 150)
        
        viewModel.startDrawing(at: startPoint)
        viewModel.addPoint(newPoint)
        
        XCTAssertEqual(viewModel.currentLine?.points.count, 2)
        XCTAssertEqual(viewModel.currentLine?.points.last?.x, newPoint.x)
        XCTAssertEqual(viewModel.currentLine?.points.last?.y, newPoint.y)
    }
    
    func testEndDrawing() {
        viewModel.selectedTool = .pencil
        let point = CGPoint(x: 100, y: 100)
        
        viewModel.startDrawing(at: point)
        viewModel.endDrawing()
        
        XCTAssertEqual(viewModel.lines.count, 1)
        XCTAssertNil(viewModel.currentLine)
    }
    
    // MARK: - Lasso Selection Tests
    
    func testLassoSelection() {
        viewModel.selectedTool = .lasso
        let points = [
            CGPoint(x: 100, y: 100),
            CGPoint(x: 200, y: 100),
            CGPoint(x: 200, y: 200),
            CGPoint(x: 100, y: 200)
        ]
        
        viewModel.startDrawing(at: points[0])
        for point in points.dropFirst() {
            viewModel.addPoint(point)
        }
        viewModel.endDrawing()
        
        XCTAssertNotNil(viewModel.selectedArea)
        XCTAssertEqual(viewModel.selectedArea?.origin.x, 100)
        XCTAssertEqual(viewModel.selectedArea?.origin.y, 100)
        XCTAssertEqual(viewModel.selectedArea?.size.width, 100)
        XCTAssertEqual(viewModel.selectedArea?.size.height, 100)
    }
    
    // MARK: - Canvas Management Tests
    
    func testClearSelection() {
        viewModel.selectedTool = .lasso
        let point = CGPoint(x: 100, y: 100)
        
        viewModel.startDrawing(at: point)
        viewModel.endDrawing()
        
        XCTAssertNotNil(viewModel.selectedArea)
        
        viewModel.clearSelection()
        
        XCTAssertNil(viewModel.selectedArea)
        XCTAssertNil(viewModel.currentSelection)
        XCTAssertNil(viewModel.recognizedText)
    }
    
    func testClearCanvas() {
        viewModel.selectedTool = .pencil
        let point = CGPoint(x: 100, y: 100)
        
        viewModel.startDrawing(at: point)
        viewModel.endDrawing()
        
        XCTAssertEqual(viewModel.lines.count, 1)
        
        viewModel.clearCanvas()
        
        XCTAssertTrue(viewModel.lines.isEmpty)
        XCTAssertNil(viewModel.selectedArea)
        XCTAssertNil(viewModel.currentSelection)
        XCTAssertNil(viewModel.recognizedText)
    }
}
