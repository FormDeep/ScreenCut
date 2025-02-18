import Foundation
import SwiftUI
import ScreenCaptureKit
import AppKit
import Combine

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
    var cancellable: AnyCancellable?
    var downCancelble: AnyCancellable?
    @ObservedObject private var actionItem = EditActionShareModel.shared

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.fillOverLayeralpha = 0.5
        self.lineWidth = 2.0
        self.selectedColor = NSColor.white
        
        let cutTypePublisher = NotificationCenter.default.publisher(for: .kCutTypeChange)
        let selectColorPublisher = NotificationCenter.default.publisher(for: .kSelectColorTypeChange)
        let drawSizedPublisher = NotificationCenter.default.publisher(for: .kDrawSizeTypeChange)
        let textSizePublisher = NotificationCenter.default.publisher(for: .kTextSizeTypeChange)
        let downloadPublisher = NotificationCenter.default.publisher(for: .kDownloadClick)

        cancellable = cutTypePublisher
            .merge(with: selectColorPublisher, drawSizedPublisher, textSizePublisher)
            .sink { notification in
//                print("其他的点击内容 \(notification)")
                switch notification.name {
                case .kCutTypeChange:
                    self.editFinished = true
                    self.needsDisplay = true
                case .kSelectColorTypeChange, .kDrawSizeTypeChange,.kTextSizeTypeChange:
                    if self.operView != nil &&  self.operView!.isKind(of: ScreenshotTextView.self) {
                        self.operView!.editFinished = false // 重新设置内容
                        self.operView!.needsDisplay = true
                    }
                default:
                    break
                }
                self.updateOperView()
            }
        
        downCancelble = downloadPublisher.sink { notification in
            if !self.editFinished {
                self.editFinished = true
                self.needsDisplay = true
            }
            
            self.dismissBottomView()
        }
    }
    
    func updateOperView() {
        if self.operView == nil {
            return
        }
        
        if !self.operView!.editFinished {
            self.configSubViewAttr(self.operView!)
            self.operView!.needsDisplay = true
        }
    }
    
    func configSubViewAttr(_ view: NSView) {
        var subView:OverlayProtocol = view as! OverlayProtocol
        subView.selectedColor = self.bottomEditItem.selectColor.nsColor
        if view.isKind(of: ScreenshotTextView.self) {
            (subView as! ScreenshotTextView).textSize = CGFloat(self.bottomEditItem.textSize)
            (subView as! ScreenshotTextView).update()
        }
        else {
            subView.lineWidth = CGFloat(self.bottomEditItem.sizeType.rawValue)
        }
    }
    
    func addCustomSubviews() {
        let subView = self.getSubView()
        guard subView != nil else {
            return
        }
        
//        删除空的页面
        if self.operView != nil && self.operView!.isKind(of: ScreenshotTextView.self) {
            let view:ScreenshotTextView = self.operView as! ScreenshotTextView
            if (view.isEmptyText()) {
                view.removeFromSuperview()
                self.operViews.remove(at: self.operViews.firstIndex(of: view)!)
            }
        }
        
        let curView:ScreenshotBaseOverlayView = subView!
        self.configSubViewAttr(curView)
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
            self.becomeFirstResponder()
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
//        print("lt -- super mouse down")
        
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
                    self.operView?.editFinished = false
                    self.operView?.needsDisplay = true
                    self.operView?.mouseDown(with: event)
                }
                else {
//                    print("lt -- add subviews inner ")
                    self.isFindForDown = false
                    self.operView?.editFinished = true
                    self.operView?.needsDisplay = true // 刷新这个View
                    self.addCustomSubviews()
                    self.operView?.editFinished = false
                    self.operView?.mouseDown(with: event)
                }
            }
            else {
//                print("lt -- add subviews outer ")
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
//        print("lt -- 这个键盘按键：\(event)")
        switch event.keyCode {
        case 36: // 回车键盘
            actionItem.actionType = .download
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
//            print("lt -- index:\(String(describing: index)) curView:\(curView)")
            self.operViews.remove(at: index!)
            self.operView = nil
        default:
            print("nothing aim at")
        }
    }
    
    override func mouseUp(with event: NSEvent) {
//        print("lt -- super mouseup")

        if self.editFinished {
            guard let subView = self.operView else {
//                print("lt -- subview is nil")
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
//        print("lt -- moved: \(self.editFinished)")
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
//        print("lt -- active handle \(activeHandle)")
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
    
    func moveWindowToScreen(window: NSWindow, targetScreenId: CGDirectDisplayID) {
        guard NSScreen.screens.count > 1 else {
            return
        }
        
        let display: NSScreen = findCurrentScreen(
            id: AppDelegate.shared.screentId!,
            screens: NSScreen.screens
        )!

        let screenFrame = display.frame
        let windowFrame = window.frame
        print("lt -- screen frame : \(screenFrame)")
        print("lt -- window size: \(windowFrame)")
        
        let originPoint = getBottomFrameOrigin()
        let newOrigin = NSMakePoint(
            originPoint.x + screenFrame.origin.x,
            originPoint.y + screenFrame.origin.y
        )
        print("lt -- selectionArea: \(self.selectionRect) \(newOrigin)")
        window.setFrameOrigin(newOrigin)
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
            moveWindowToScreen(window: areaPanel, targetScreenId: AppDelegate.shared.screentId!)
        }
        else {
            self.bottomAreaWindow!.setFrameOrigin(self.getBottomFrameOrigin())
            moveWindowToScreen(
                window: self.bottomAreaWindow!,
                targetScreenId: AppDelegate.shared.screentId!
            )
            self.bottomAreaWindow!.orderFront(self)
        }
        self.bottomAreaWindow!.setIsVisible(true)
    }
    
    func dismissBottomView() {
        if (self.bottomAreaWindow != nil) && self.bottomAreaWindow!.isVisible {
            self.bottomAreaWindow?.setIsVisible(false)
        }
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
