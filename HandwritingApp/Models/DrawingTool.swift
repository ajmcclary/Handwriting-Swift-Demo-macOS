import SwiftUI

/// Represents the available drawing tools in the application
enum DrawingTool: String, CaseIterable {
    case pencil
    case eraser
    case lasso
    
    var systemImageName: String {
        switch self {
        case .pencil:
            return "pencil"
        case .eraser:
            return "eraser"
        case .lasso:
            return "lasso"
        }
    }
}

/// Represents a point in the drawing
struct DrawingPoint: Equatable {
    let x: CGFloat
    let y: CGFloat
    let pressure: CGFloat
    
    static func ==(lhs: DrawingPoint, rhs: DrawingPoint) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y && lhs.pressure == rhs.pressure
    }
}

/// Represents a line in the drawing
struct DrawingLine: Identifiable {
    let id = UUID()
    var points: [DrawingPoint]
    var color: Color
    var lineWidth: CGFloat
}

/// Represents a selection made with the lasso tool
struct LassoSelection {
    var points: [DrawingPoint]
    var boundingBox: CGRect?
    
    mutating func updateBoundingBox() {
        guard !points.isEmpty else {
            boundingBox = nil
            return
        }
        
        let xPoints = points.map { $0.x }
        let yPoints = points.map { $0.y }
        
        let minX = xPoints.min() ?? 0
        let maxX = xPoints.max() ?? 0
        let minY = yPoints.min() ?? 0
        let maxY = yPoints.max() ?? 0
        
        boundingBox = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    func contains(_ point: CGPoint) -> Bool {
        // Ray casting algorithm to determine if a point is inside a polygon
        var inside = false
        var j = points.count - 1
        
        for i in 0..<points.count {
            let pi = CGPoint(x: points[i].x, y: points[i].y)
            let pj = CGPoint(x: points[j].x, y: points[j].y)
            
            if ((pi.y > point.y) != (pj.y > point.y)) &&
                (point.x < (pj.x - pi.x) * (point.y - pi.y) / (pj.y - pi.y) + pi.x) {
                inside = !inside
            }
            j = i
        }
        
        return inside
    }
}
