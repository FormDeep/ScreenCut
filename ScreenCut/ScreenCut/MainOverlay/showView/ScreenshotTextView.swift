import Foundation
import SwiftUI
import ScreenCaptureKit
import AppKit
import Combine

// 文本内容
class ScreenshotTextView: ScreenshotBaseOverlayView , NSTextViewDelegate{
    var maxFrame: NSRect?
    var fillOverLayeralpha: CGFloat = 0.0 // 默认值
    var textSize: CGFloat = 12.0
    var textView: NSTextView = NSTextView(frame: NSMakeRect(0, 0, 0, 0))
    var textIsEditing = false
    var dragIng: Bool = false
    var lastMouseLoc: NSPoint?
    let controlPointDiameter: CGFloat = 8.0
    var textCancellables = Set<AnyCancellable>()
    var activeHandle: RetangleResizeHandle = .none

    var hasSelectionRect: Bool {
        return (self.textView.frame.size.width > 0 && self.textView.frame.size.height > 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.lineWidth = 2.0
        self.textView.backgroundColor = .clear
        self.textView.isVerticallyResizable = true
        self.textView.textContainer?.widthTracksTextView = true  // 让宽度自动跟踪 textView 的宽度
        self.addSubview(self.textView)
    }
    
    func update() {
        self.textView.textColor = self.selectedColor
        self.textView.font = .systemFont(ofSize: self.textSize)
        self.needsLayout = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
    }

    func textShouldEndEditing(_ textObject: NSText) -> Bool {
        return true
    }
    
    func textDidBeginEditing(_ notification: Notification) {
        self.textIsEditing = true
    }
    
    func textDidEndEditing(_ notification: Notification) {
        print("textDidEndEditing")
        self.textIsEditing = false
    }
    
    func textDidChange(_ notification: Notification) {
        self.needsDisplay = true
    }
    
    func isEmptyText() -> Bool {
         let curString: String = self.textView.string.trimmingCharacters(in: .whitespacesAndNewlines)
        return curString.count == 0
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        if (self.textView.frame.size.width <= 1.0) {
            self.textView.frame = NSMakeRect(location.x, location.y, self.textSize * 6, self.textSize + 6)
            self.textView.delegate = self;
            self.window?.makeFirstResponder(self.textView)
            self.textView.font = .systemFont(ofSize: self.textSize)
            self.textView.textColor = self.selectedColor
            self.textView.layer?.cornerRadius = 4.0
            self.textView.wantsLayer = true
            self.textView.layer?.borderWidth = 2.0
            self.textView.layer?.borderColor = NSColor.gray.cgColor
            self.textView.layer?.masksToBounds = true
        }
        else {
            self.window?.makeFirstResponder(nil)
            self.activeHandle = handleForPoint(location)
            if self.isOnBorderAt(location) {
                self.dragIng = true
                self.lastMouseLoc = convert(event.locationInWindow, from: nil)
            }
            
            if self.textView.string.count == 0 {
                self.textView.frame = NSRect.zero
            }
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        let loc = convert(event.locationInWindow, from: nil)
        
        if activeHandle != .none {
            var newRect = self.textView.frame
            let lastLocation = self.lastMouseLoc
            
            let deltaX = loc.x - lastLocation!.x
            let deltaY = loc.y - lastLocation!.y
            print("tt -- dragged Move : \(deltaX) , deltaY: \(deltaY)")
            
            switch activeHandle {
            case .topLeft:
                newRect.origin.x = min(newRect.origin.x + newRect.size.width - 20, newRect.origin.x + deltaX)
                newRect.size.width = max(20, newRect.size.width - deltaX)
                newRect.size.height = max(20, newRect.size.height + deltaY)
            case .top:
                newRect.size.height = max(20, newRect.size.height + deltaY)
            case .topRight:
                newRect.size.width = max(20, newRect.size.width + deltaX)
                newRect.size.height = max(20, newRect.size.height + deltaY)
            case .right:
                newRect.size.width = max(20, newRect.size.width + deltaX)
            case .bottomRight:
                newRect.origin.y = min(newRect.origin.y + newRect.size.height - 20, newRect.origin.y + deltaY)
                newRect.size.width = max(20, newRect.size.width + deltaX)
                newRect.size.height = max(20, newRect.size.height - deltaY)
            case .bottom:
                newRect.origin.y = min(newRect.origin.y + newRect.size.height - 20, newRect.origin.y + deltaY)
                newRect.size.height = max(20, newRect.size.height - deltaY)
            case .bottomLeft:
                newRect.origin.y = min(newRect.origin.y + newRect.size.height - 20, newRect.origin.y + deltaY)
                newRect.origin.x = min(newRect.origin.x + newRect.size.width - 20, newRect.origin.x + deltaX)
                newRect.size.width = max(20, newRect.size.width - deltaX)
                newRect.size.height = max(20, newRect.size.height - deltaY)
            case .left:
                newRect.origin.x = min(newRect.origin.x + newRect.size.width - 20, newRect.origin.x + deltaX)
                newRect.size.width = max(20, newRect.size.width - deltaX)
            default:
                break
            }
            self.textView.frame = newRect
            print("lt -- new rect : \(newRect)")
        }
        else if (self.dragIng && self.lastMouseLoc != nil) {
            let detaX = loc.x - lastMouseLoc!.x
            let detaY = loc.y - lastMouseLoc!.y
            let origin = NSMakePoint(self.textView.frame.origin.x + detaX, self.textView.frame.origin.y + detaY)
            self.textView.setFrameOrigin(origin)
        }
        self.lastMouseLoc = loc
        self.needsDisplay = true
    }
    
    override func mouseUp(with event: NSEvent) {
        print("lt -- subview mosueup")
        if (self.dragIng) {
            self.dragIng = false
        }
    }
    
    override func isOnBorderAt(_ point: NSPoint) -> Bool {
        if self.textView.bounds.size.width <= 1 {
            return false
        }
        
        return NSPoint.isPointAtFrame(point: point ,rect: self.textView.frame)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        maxFrame = dirtyRect
        
        NSColor.clear.withAlphaComponent(self.fillOverLayeralpha).setFill()
        dirtyRect.fill()
        
        if !self.hasSelectionRect {
            return
        }
        
        let rect = self.textView.frame
        // 绘制边框
        let dashedBorder = NSBezierPath(rect: rect)
        dashedBorder.lineWidth = lineWidth
        NSColor.gray.setStroke()
        dashedBorder.stroke()
        NSColor.init(white: 1, alpha: 0.01).setFill()
        //            selectedColor.setFill()
        __NSRectFill(rect)
        // 绘制边框中的点
        if (!self.editFinished) {
            for handle in RetangleResizeHandle.allCases {
                if let point = controlPointForHandle(handle, inRect: rect) {
                    let controlPointRect = NSRect(origin: point, size: CGSize(width: controlPointDiameter, height: controlPointDiameter))
                    let controlPointPath = NSBezierPath(ovalIn: controlPointRect)
                    NSColor.white.setFill()
                    controlPointPath.fill()
                }
            }
        }
    }
    
    func controlPointForHandle(_ handle: RetangleResizeHandle, inRect rect: NSRect) -> NSPoint? {
        switch handle {
        case .topLeft:
            return NSPoint(x: rect.minX - controlPointDiameter / 2 - 1, y: rect.maxY - controlPointDiameter / 2 + 1)
        case .top:
            return NSPoint(x: rect.midX - controlPointDiameter / 2, y: rect.maxY - controlPointDiameter / 2 + 1)
        case .topRight:
            return NSPoint(x: rect.maxX - controlPointDiameter / 2 + 1, y: rect.maxY - controlPointDiameter / 2 + 1)
        case .right:
            return NSPoint(x: rect.maxX - controlPointDiameter / 2 + 1, y: rect.midY - controlPointDiameter / 2)
        case .bottomRight:
            return NSPoint(x: rect.maxX - controlPointDiameter / 2 + 1, y: rect.minY - controlPointDiameter / 2 - 1)
        case .bottom:
            return NSPoint(x: rect.midX - controlPointDiameter / 2, y: rect.minY - controlPointDiameter / 2 - 1)
        case .bottomLeft:
            return NSPoint(x: rect.minX - controlPointDiameter / 2 - 1, y: rect.minY - controlPointDiameter / 2 - 1)
        case .left:
            return NSPoint(x: rect.minX - controlPointDiameter / 2 - 1, y: rect.midY - controlPointDiameter / 2)
        case .none:
            return nil
        }
    }
    
    override func handleForPoint(_ point: NSPoint) -> RetangleResizeHandle {
        if self.textView.frame.size.width < kSelectionMinWidth {
            return .none
        }
        let rect = self.textView.frame
        for handle in RetangleResizeHandle.allCases {
            if let controlPoint = controlPointForHandle(handle, inRect: rect), NSRect(origin: controlPoint, size: CGSize(width: controlPointDiameter, height: controlPointDiameter)).contains(point) {
                return handle
            }
        }
        return .none
    }
    
    override func handleborderForPoint(_ point: NSPoint) -> RetangleResizeHandle {
        if self.textView.frame.size.width < kSelectionMinWidth {
            return .none
        }
        let deta = controlPointDiameter / 2
        let rect = self.textView.frame
//         上
        if (point.x > rect.minX - deta && point.x < rect.maxX + deta && point.y > rect.maxY - deta && point.y < rect.maxY + deta) {
            return .top
        }
        
//          下
        if (point.x > rect.minX - deta && point.x < rect.maxX + deta && point.y > rect.minY - deta && point.y < rect.minY + deta) {
            return .bottom
        }
            
//        左
        if (point.x > rect.minX - deta && point.x < rect.minX + deta && point.y > rect.minY - deta && point.y < rect.maxY + deta) {
            return .left
        }
//         右
        if (point.x > rect.maxX - deta && point.x < rect.maxX + deta && point.y > rect.minY - deta && point.y < rect.maxY + deta) {
            return .right
        }
        
        return .none
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        let hitView = super.hitTest(point)
        if hitView == self {
            return self.superview
        }
        return hitView
    }
}


