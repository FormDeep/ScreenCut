import Cocoa

class ScreenshotDoodleView: NSView, OverlayProtocol {
    private var lines: [[NSPoint]] = [] // 存储绘制的线条
    private var currentLine: [NSPoint] = [] // 当前正在绘制的线条
    var size: NSSize = NSSize.zero
    var selectedColor: NSColor = NSColor.white
    var lineWidth: CGFloat = 4.0
    
    init(frame: CGRect, size: NSSize) {
        self.size = size
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func mouseDown(with event: NSEvent) {
        // 开始新的线条
        currentLine = []
        let point = convert(event.locationInWindow, from: nil)
        currentLine.append(point)
    }

    override func mouseDragged(with event: NSEvent) {
        // 继续绘制线条
        let point = convert(event.locationInWindow, from: nil)
        currentLine.append(point)
        needsDisplay = true // 标记为需要重绘
    }

    override func mouseUp(with event: NSEvent) {
        // 结束当前线条
        if !currentLine.isEmpty {
            lines.append(currentLine)
            currentLine = []
            needsDisplay = true
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // 设置绘制颜色
        selectedColor.setStroke()

        // 绘制已存储的线条
        for line in lines {
            if line.count > 1 {
                let path = NSBezierPath()
                path.lineWidth = lineWidth
                path.move(to: line[0])
                for point in line.dropFirst() {
                    path.line(to: point)
                }
                path.stroke()
            }
        }

        // 绘制当前线条
        if !currentLine.isEmpty {
            let path = NSBezierPath()
            path.lineWidth = lineWidth
            path.move(to: currentLine[0])
            for point in currentLine.dropFirst() {
                path.line(to: point)
            }
            path.stroke()
        }
    }
}

