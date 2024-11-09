import Foundation
import SwiftUI
import ScreenCaptureKit
import AppKit


let kBottomEditRowHeight: CGFloat = 45.0
let kBottomEditRowWidth: CGFloat = 340

// 蒙层页面
class ScreenshotOverlayView: ScreenshotRectangleView {
    
    override var canBecomeKeyView: Bool {
        return true
    }
    
    var bottomAreaWindow: NSWindow? // 当前的主View
    var bottomEditItem = EditCutBottomShareModel.shared
    var operViews = Array<NSView>() // 存储所有的子View
    var operView: ScreenshotBaseOverlayView? // 当前操作的View
    var isFindForDown = false  // 在mousedown中是不是查找的方式
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.fillOverLayeralpha = 0.5
        NotificationCenter.default.addObserver(self, selector: #selector(cutTypeChange), name: Notification.Name(kCutTypeChange), object: nil)
    }
    
    @objc func cutTypeChange(_ notification: Notification) {
        self.editFinished = true
        needsDisplay = true
    }
    
    func configSubViewAttr(_ view: NSView) {
        var subView:OverlayProtocol = view as! OverlayProtocol
        subView.selectedColor = self.bottomEditItem.selectColor.nsColor
        subView.lineWidth = CGFloat(self.bottomEditItem.sizeType.rawValue)
    }
    
    func addCustomSubviews() {
        let subView = self.getSubView()
        print("lt -- add suview : \(String(describing: subView))")
        guard subView != nil else {
            return
        }
        
        let curView:ScreenshotBaseOverlayView = subView!
        self.addSubview(curView)
        curView.wantsLayer = true;
        curView.layer?.masksToBounds = true
        self.operViews.append(curView)
        self.operView = curView
        curView.needsDisplay = true
    }
    
    func getSubView() -> ScreenshotBaseOverlayView? {
        var subView: ScreenshotBaseOverlayView?
        switch self.bottomEditItem.cutType {
        case .square:
            subView = ScreenshotRectangleView(frame: self.selectionRect)
        case .circle:
            subView = ScreenshotCircleView(frame: self.selectionRect)
        case .arrow:
            subView = ScreenshotArrowView(frame: self.selectionRect)
        case .doodle:
            subView = ScreenshotDoodleView(frame: self.selectionRect)
        case .text:
            subView = ScreenshotTextView(frame: self.selectionRect)
        default:
            break
        }
        return subView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if self.window != nil {
            let trackingArea = NSTrackingArea(rect: self.bounds,
                                              options: [.mouseEnteredAndExited, .mouseMoved, .cursorUpdate, .activeInActiveApp],
                                              owner: self,
                                              userInfo: nil)
            self.addTrackingArea(trackingArea)
            ScreenCut.screenArea = self.selectionRect
            self.fillOverLayeralpha = 0.5
            self.selectedColor = .white
        } else {
            self.bottomEditItem.cutType = .none
            self.bottomEditItem.selectColor = .red
            self.bottomEditItem.sizeType = .Two
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.gray.withAlphaComponent(0.3).setFill()
        super.draw(dirtyRect)
    }
    
    override func mouseDragged(with event: NSEvent) {
        if self.editFinished {
            self.operView?.mouseDragged(with: event)
            return
        }
        
        super.mouseDragged(with: event)
    }
    
    override func mouseDown(with event: NSEvent) {
        print("lt -- super mouse down")
        
        if (self.editFinished) {
//            0 是否有ziviews，如果没有，就添加，如果有就进行1处理
//            1、是否在线上，
//            1.1 在， 处理
//            1.2 不再 将上一个ziview设置unedit 就创建新的ziview，
            if (self.subviews.count > 0 ) {
                var findView: ScreenshotBaseOverlayView?
                for element in self.subviews.reversed() {
                    //                1、 在顶点上
                    //                2、 在边上
                    if !element.isKind(of: ScreenshotBaseOverlayView.self) {
                        return
                    }
                    let view: ScreenshotBaseOverlayView = element as! ScreenshotBaseOverlayView
//                    let borerHande = view.handleborderForPoint(convert(event.locationInWindow, to: view))
                    let isOnBorder = view.isOnBorderAt(convert(event.locationInWindow, to: view))
                    if isOnBorder {
                        findView = view
                        break
                    }
                }
                
               
                if let view = findView {
                    print("ltl -- mouse down find: \(view)")
                    if (self.operView != findView) {
                        self.operView?.editFinished = true // 将前面一个设置结束编辑
                        self.operView?.needsDisplay = true // 刷新这个View
                        self.operView = view
                    }
                    self.isFindForDown = true // 按下的时候找到了这个内容
                }
                else {
                    print("lt -- add subviews inner ")
                    self.isFindForDown = false
                    self.operView?.editFinished = true
                    self.operView?.needsDisplay = true // 刷新这个View
                    self.addCustomSubviews()
                    
                }
                self.operView?.editFinished = false
                self.operView?.mouseDown(with: event)
            }
            else {
                print("lt -- add subviews outer ")
                self.isFindForDown = false
                self.operView?.editFinished = true
                self.addCustomSubviews()
                self.operView?.mouseDown(with: event)
            }

            return
        }
        
        super.mouseDown(with: event)
        
        if self.hasSelectionRect, NSPointInRect(convert(event.locationInWindow, to: self), self.selectionRect) {
            dragIng = true
        }
        
        if let pannel = self.bottomAreaWindow {
            pannel.orderBack(nil)
            pannel.setIsVisible(false)
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }

    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func keyDown(with event: NSEvent) {
        print("lt -- 这个键盘按键：\(event)")
        switch event.keyCode {
        case 51:
//             删除按键
            guard let curView = self.operView else {
                Toast(message: "目前没有选中要删除的页面").show(in: self)
                return
            }
            curView.removeFromSuperview()
            self.operViews.remove(at: self.operViews.firstIndex(of: curView)!)
            self.operView = nil
        case 6:
//            command + z
//            直接从views的最后一个开始删除
            let lastView = self.operViews.last
            guard let curView = lastView else {
                Toast(message: "没有操作可回退了").show(in: self)
                return
            }
            curView.removeFromSuperview()
            let index = self.operViews.firstIndex(of: curView)
            print("lt -- index:\(String(describing: index)) curView:\(curView)")
            self.operViews.remove(at: index!)
            self.operView = nil
        default:
            print("nothing aim at")
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        print("lt -- super mouseup")

        if self.editFinished {
            guard let subView = self.operView else {
                print("lt -- subview is nil")
                return
            }
            if (self.isFindForDown) {
                subView.editFinished = false
            }
            else {
                subView.editFinished = true
            }
            self.operView?.needsDisplay = true
            self.operView?.mouseUp(with: event)
//            print("lt -- 当前绘制的页面： \(subView) \(subView.editFinished) \(self.isFindForDown)")
            return
        }
        
        super.mouseUp(with: event)
        
        if self.hasSelectionRect {
            ScreenCut.screenArea = self.selectionRect
        }
        
        self.showEditCutBottomView()
    }
    
    
    //    添加在这个上面的View就不要实现这个方法了
    //    主要鼠标
    override func mouseMoved(with event: NSEvent) {
//        print("lt -- moved: \(event)")
        if (self.editFinished) {
            if (self.subviews.count > 0) {
                for element in self.subviews.reversed() {
                    //                1、 在顶点上
                    //                2、 在边上
                    if !element.isKind(of: ScreenshotBaseOverlayView.self) {
                        return
                    }
                    let view: ScreenshotBaseOverlayView = element as! ScreenshotBaseOverlayView
                    
                    // 在顶点上
                    if (!view.editFinished) { //在编辑中，就显示这种
                        let handle = view.handleForPoint(convert(event.locationInWindow, to: view))
//                        print("lt -- handle : \(handle)")
                        if (handle != .none) {
                            switch handle {
                            case .top, .bottom:
                                NSCursor.frameResize(position: .top, directions: [.inward, .outward]).set()
                            case .left, .right:
                                NSCursor.frameResize(position: .left, directions: [.inward, .outward]).set()
                            case .topLeft, .bottomRight:
                                NSCursor.frameResize(position: .topLeft, directions: [.inward, .outward]).set()
                            case .topRight, .bottomLeft:
                                NSCursor.frameResize(position: .topRight, directions: [.inward, .outward]).set()
                            default:
                                break
                            }
                            return
                        }
                    }
                    
                    // 2、在边线上
                    let isOnBorder = view.isOnBorderAt(convert(event.locationInWindow, to: view))
//                    print("lt -- borerHande : \(isOnBorder)")
                    if isOnBorder {
                        NSCursor.openHand.set()
                        return
                    }
                }
            }
            
            if self.selectionRect.contains(convert(event.locationInWindow, to: self)) {
                NSCursor.crosshair.set()
            }
            else {
                NSCursor.arrow.set()
            }
            
            return
        }
        
        
        let curlocation = convert(event.locationInWindow, from: nil)
        activeHandle = self.handleForPoint(curlocation)
        if (activeHandle != .none) {
            switch activeHandle {
            case .top, .bottom:
                NSCursor.frameResize(position: .top, directions: [.inward, .outward]).set()
            case .left, .right:
                NSCursor.frameResize(position: .left, directions: [.inward, .outward]).set()
            case .topLeft, .bottomRight:
                NSCursor.frameResize(position: .topLeft, directions: [.inward, .outward]).set()
            case .topRight, .bottomLeft:
                NSCursor.frameResize(position: .topRight, directions: [.inward, .outward]).set()
            default:
                break
            }
            return
        }
        else {
            if self.selectionRect.contains(curlocation) {
                NSCursor.closedHand.set()
            }
            else {
                NSCursor.crosshair.set()
            }
        }
    }
    
    var EditCutHeight: CGFloat {
        if (bottomEditItem.cutType != .none) {
            return kBottomEditRowHeight * 2
        }
        else {
            return kBottomEditRowHeight
        }
    }
    
    
    
    func showEditCutBottomView() {
        if (bottomAreaWindow == nil) {
            let contentView = NSHostingView(rootView: EditCutBottomView())
            contentView.frame = NSRect(x: self.getBottomFrameOrigin().x, y:self.getBottomFrameOrigin().y, width: contentView.frame.size.width, height: contentView.frame.size.height)
            contentView.focusRingType = .none
            let areaPanel = EditCutBottomPanel(contentRect: contentView.frame, styleMask: [.fullSizeContentView], backing: .buffered, defer: false)
            areaPanel.collectionBehavior = [.canJoinAllSpaces]
            areaPanel.setFrame(contentView.frame, display: true)
            areaPanel.level = .screenSaver
            areaPanel.title = kEditImageText
            areaPanel.contentView = contentView
            areaPanel.backgroundColor = .clear
            areaPanel.titleVisibility = .hidden
            areaPanel.isReleasedWhenClosed = false
            areaPanel.titlebarAppearsTransparent = true
            areaPanel.isMovableByWindowBackground = true
            areaPanel.orderFront(nil)
            self.bottomAreaWindow =  areaPanel
        }
        else {
            self.bottomAreaWindow!.setFrameOrigin(self.getBottomFrameOrigin())
            self.bottomAreaWindow!.orderFront(self)
        }
        self.bottomAreaWindow!.setIsVisible(true)
    }
    
    func getBottomFrameOrigin() -> NSPoint {
        let originX: CGFloat = selectionRect.origin.x + selectionRect.size.width - kBottomEditRowWidth
        var originY: CGFloat = selectionRect.origin.y - self.EditCutHeight
        if originY < kBottomEditRowHeight {
            originY = kBottomEditRowHeight;
        }
        return NSMakePoint(originX, originY)
    }
    
}
