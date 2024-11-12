import Cocoa

class ScreenshotDoodleView: ScreenshotBaseOverlayView {
//    private var lines: [[NSPoint]] = [] // 存储绘制的线条
    private var currentLine: [NSPoint] = [] // 当前正在绘制的线条
//    var selectedColor: NSColor = NSColor.white
//    var lineWidth: CGFloat = 4.0
    var dragIng: Bool = false
    var dragLastLoc: NSPoint?
    let controlPointColor: NSColor = NSColor.white
    var drawExpendEnd: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseDown(with event: NSEvent) {
        // 开始新的线条
        let point = convert(event.locationInWindow, from: nil)
        print("lt -- mouseDown point: \(point)")
        let isAtPoint = self.isOnBorderAt(point)
        print("lt -- is at point: \(isAtPoint)")
        if isAtPoint {
            if (self.isAtEndPoint(point)) {
                self.drawExpendEnd = self.isAtLastEndPoint(point)
            }
            else {
                // 拖拽
                self.dragIng = true
                self.dragLastLoc = point
            }
        }
        else {
            currentLine.append(point)
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        if self.dragIng && self.dragLastLoc != nil {
            if self.currentLine.count == 0 { return }
            var transLine:[NSPoint] = []
            let doodlePoints:[NSPoint] = currentLine
            let detaX = point.x - self.dragLastLoc!.x
            let detaY = point.y - self.dragLastLoc!.y
            for index in 0..<doodlePoints.count {
                let curPoint = NSMakePoint(doodlePoints[index].x + detaX, doodlePoints[index].y + detaY)
                transLine.append(curPoint)
            }
            currentLine = transLine
            self.dragLastLoc = point
        }
        else {
            if (!self.drawExpendEnd) {
                currentLine.insert(point, at: 0)
            }
            else {
                currentLine.append(point)
            }
//            currentLine.append(point)
        }
        self.needsDisplay = true

    }
    
    override func mouseUp(with event: NSEvent) {
        if (self.dragIng) {
            self.dragIng = false
        }
        needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // 设置绘制颜色
        selectedColor.setStroke()
        
        // 绘制当前线条
        if !currentLine.isEmpty {
            let path = NSBezierPath()
            path.lineWidth = lineWidth
            path.move(to: currentLine[0])
            for point in currentLine.dropFirst() {
                path.line(to: point)
            }
            path.stroke()
            
            if !self.editFinished {
                //                first point
                do {
                    let point = currentLine.first!
                    let controlPointRect = NSRect(origin: NSMakePoint(point.x - 5, point.y - 5), size: CGSize(width: 10, height: 10))
                    let controlPointPath = NSBezierPath(ovalIn: controlPointRect)
                    controlPointColor.setFill()
                    controlPointPath.fill()
                }

                //                 last point
                do {
                    let point = currentLine.last!
                    let controlPointRect = NSRect(origin: NSMakePoint(point.x - 5, point.y - 5), size: CGSize(width: 10, height: 10))
                    let controlPointPath = NSBezierPath(ovalIn: controlPointRect)
                    controlPointColor.setFill()
                    controlPointPath.fill()
                }
            }
        }
        
    }
    
    override func isOnBorderAt(_ point: NSPoint) -> Bool {
        return NSPoint.isPointOnDoodleLine(doodlePoints: self.currentLine, pointToCheck: point)
    }
    
    func isAtEndPoint(_ point: NSPoint) -> Bool {
        if (currentLine.count < 2) { return false}
        return self.isAtFirstEndPoint(point) || self.isAtLastEndPoint(point)
    }
    
    func isAtFirstEndPoint(_ point: NSPoint) -> Bool {
        let first = currentLine.first!
        return (abs(first.x - point.x) < 4 && abs(first.y - point.y) < 4)
    }
    
    func isAtLastEndPoint(_ point: NSPoint) -> Bool {
        let last = currentLine.last!
        return (abs(last.x - point.x) < 4 && abs(last.y - point.y) < 4)
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        let hitView = super.hitTest(point)
        if hitView == self {
            return self.superview
        }
        return hitView
    }
}

