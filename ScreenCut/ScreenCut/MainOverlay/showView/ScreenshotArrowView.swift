import Foundation
import SwiftUI
import ScreenCaptureKit
import AppKit

//椭圆形
class ScreenshotArrowView: ScreenshotBaseOverlayView {
    
    var selectionRect: NSRect = NSRect.zero
    var initialLocation: NSPoint?
    var dragIng: Bool = false
    var activeHandle: RetangleResizeHandle = .none
    var lastMouseLocation: NSPoint?
    var maxFrame: NSRect?
    let controlPointDiameter: CGFloat = 8.0
    let controlPointColor: NSColor = NSColor.white
    var fillOverLayeralpha: CGFloat = 0.0 // 默认值
    var selectedColor: NSColor = NSColor.white
    var lineWidth: CGFloat = 2.0
    var hasSelectionRect: Bool {
        return (self.selectionRect.size.width > 0 && self.selectionRect.size.height > 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
//        let trackingArea = NSTrackingArea(rect: self.bounds,
//                                          options: [.mouseEnteredAndExited, .mouseMoved, .cursorUpdate, .activeInActiveApp],
//                                          owner: self,
//                                          userInfo: nil)
//        self.addTrackingArea(trackingArea)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        maxFrame = dirtyRect
        
        lineWidth = CGFloat(EditCutBottomShareModel.shared.sizeType.rawValue)
        selectedColor = EditCutBottomShareModel.shared.selectColor.nsColor

        
        NSColor.red.withAlphaComponent(fillOverLayeralpha).setFill()
        dirtyRect.fill()
        
        if (!self.hasSelectionRect) {
            return
        }
        
        let rect = selectionRect
            let mousePoint: NSPoint = lastMouseLocation!

            // 设置箭头的颜色
//            NSColor.blue.setFill()
            NSColor.clear.setFill()
            selectedColor.setStroke()
            
            // 创建箭头路径
            let arrowPath = NSBezierPath()
            
            // 箭头的起点
            let arrowStart = initialLocation!
            arrowPath.move(to: arrowStart)
            
            // 箭头的主干
            arrowPath.line(to: mousePoint)
            
            // 箭头的尖端
            let arrowLength: CGFloat = 20.0
            let angle: CGFloat = atan2(mousePoint.y - arrowStart.y, mousePoint.x - arrowStart.x)
            
            let arrowHead1 = NSPoint(x: mousePoint.x - arrowLength * cos(angle - .pi / 6),
                                     y: mousePoint.y - arrowLength * sin(angle - .pi / 6))
            let arrowHead2 = NSPoint(x: mousePoint.x - arrowLength * cos(angle + .pi / 6),
                                     y: mousePoint.y - arrowLength * sin(angle + .pi / 6))
            
            arrowPath.line(to: arrowHead1)
            arrowPath.move(to: mousePoint)
            arrowPath.line(to: arrowHead2)
            
            // 完成路径
            arrowPath.lineWidth = lineWidth
            arrowPath.stroke()
            
            // 绘制边框中的点
            if (!editFinished) {
                for handle in RetangleResizeHandle.allCases {
                    if let point = controlPointForHandle(handle, inRect: rect) {
                        let controlPointRect = NSRect(origin: point, size: CGSize(width: controlPointDiameter, height: controlPointDiameter))
                        let controlPointPath = NSBezierPath(ovalIn: controlPointRect)
                        controlPointColor.setFill()
                        controlPointPath.fill()
                    }
                }
            }
    }
    
    override func handleForPoint(_ point: NSPoint) -> RetangleResizeHandle {
        if !self.hasSelectionRect {
            return .none
        }
        let rect = self.selectionRect
        for handle in RetangleResizeHandle.allCases {
            if let controlPoint = controlPointForHandle(handle, inRect: rect), NSRect(origin: controlPoint, size: CGSize(width: controlPointDiameter, height: controlPointDiameter)).contains(point) {
                return handle
            }
        }
        return .none
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
    
    override func mouseDragged(with event: NSEvent) {
        guard var initialLocation = initialLocation else { return }
        let currentLocation = convert(event.locationInWindow, from: nil)
        
        if activeHandle != .none {
            var newRect = selectionRect ?? CGRect.zero
            let lastLocation = lastMouseLocation ?? currentLocation
            
            let deltaX = currentLocation.x - lastLocation.x
            let deltaY = currentLocation.y - lastLocation.y
            
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
            self.selectionRect = newRect
            initialLocation = currentLocation // Update initial location for continuous dragging
        } else {
            if dragIng {
                dragIng = true
                // 计算移动偏移量
                let deltaX = currentLocation.x - initialLocation.x
                let deltaY = currentLocation.y - initialLocation.y
                
                // 更新矩形位置
                let x = self.selectionRect.origin.x
                let y = self.selectionRect.origin.y
                let w = self.selectionRect.size.width
                let h = self.selectionRect.size.height
                self.selectionRect.origin.x = min(max(0.0, x + deltaX), self.frame.width - w)
                self.selectionRect.origin.y = min(max(0.0, y + deltaY), self.frame.height - h)
                initialLocation = currentLocation
            } else {
                // 创建新矩形
                guard let maxFrame = maxFrame else { return }
                let origin = NSPoint(x: max(maxFrame.origin.x, min(initialLocation.x, currentLocation.x)), y: max(maxFrame.origin.y, min(initialLocation.y, currentLocation.y)))
                var maxH = abs(currentLocation.y - initialLocation.y)
                var maxW = abs(currentLocation.x - initialLocation.x)
                if currentLocation.y < maxFrame.origin.y { maxH = initialLocation.y }
                if currentLocation.x < maxFrame.origin.x { maxW = initialLocation.x }
                let size = NSSize(width: maxW, height: maxH)
                self.selectionRect = NSIntersectionRect(maxFrame, NSRect(origin: origin, size: size))
            }
            self.initialLocation = initialLocation
        }
        lastMouseLocation = currentLocation
        needsDisplay = true
    }
    
    override func mouseDown(with event: NSEvent) {
        
        let location = convert(event.locationInWindow, from: nil)
        initialLocation = location
        lastMouseLocation = location
        activeHandle = handleForPoint(location)
        if NSPointInRect(location, self.selectionRect) {
            self.dragIng = true
        }
        needsDisplay = true
    }
    
    override func mouseUp(with event: NSEvent) {
        //        initialLocation = nil
        activeHandle = .none
        dragIng = false
        needsDisplay = true
        self.addSubviewFromSuperView()
    }
    
    func addSubviewFromSuperView() {
        self.editFinished = true
        let superView: ScreenshotOverlayView = self.superview as! ScreenshotOverlayView
        superView.addCustomSubviews()
    }
    
    override func mouseMoved(with event: NSEvent) {
//        let curlocation = event.locationInWindow
//        activeHandle = handleForPoint(curlocation)
//        if (activeHandle != .none) {
//            switch activeHandle {
//            case .top, .bottom:
//                NSCursor.frameResize(position: .top, directions: [.inward, .outward]).set()
//            case .left, .right:
//                NSCursor.frameResize(position: .left, directions: [.inward, .outward]).set()
//            case .topLeft, .bottomRight:
//                NSCursor.frameResize(position: .topLeft, directions: [.inward, .outward]).set()
//            case .topRight, .bottomLeft:
//                NSCursor.frameResize(position: .topRight, directions: [.inward, .outward]).set()
//            default:
//                NSCursor.resizeLeftRight.set()
//                break
//            }
//        }
//        else {
////            if (self.selectionRect.contains(curlocation)) {
////                NSCursor.closedHand.set()
////            }
////            else {
////                NSCursor.crosshair.set()
////            }
//        }
    }
    override func hitTest(_ point: NSPoint) -> NSView? {
        let hitView = super.hitTest(point)
        if hitView == self {
            return self.superview
        }
        return hitView
    }
}


