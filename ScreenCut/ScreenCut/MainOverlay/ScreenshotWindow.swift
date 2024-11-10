//
//  ScreenshotWindow.swift
//  ScreenCut
//
//  Created by helinyu on 2024/11/3.
//

import Foundation
import AppKit

class ScreenshotWindow: NSWindow {
    
    var parentView:ScreenshotOverlayView?
    
    init(_ contentRect: NSRect = NSScreen.main!.frame, backing bufferingType: NSWindow.BackingStoreType = .buffered, defer flag: Bool = false, size: NSSize = NSSize.zero) {
        super.init(contentRect: contentRect, styleMask: [  .closable, .borderless,.resizable], backing: bufferingType, defer: flag)
        let overlayView = ScreenshotOverlayView(frame: contentRect)
        self.isOpaque = false
        self.hasShadow = false
        self.level = .screenSaver - 1
        self.title = kAreaSelector
        self.backgroundColor = NSColor.clear
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isReleasedWhenClosed = false
//        self.contentView?.addSubview(overlayView)
//        print("lt -- content view: \(String(describing: self.contentView))")
//        self.contentView = overlayView
        self.contentView?.addSubview(overlayView)
        parentView = overlayView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var canBecomeKey: Bool {
       return true
    }
}

//class OverlayWindow: NSWindow {
//    override var canBecomeKey: Bool {
//       return true
//    }
//}
//
//class ScreenshotOverlayWindowController: NSWindowController {
//    
//    convenience init() {
//    
//        let windowFrame = CGRectMake(0, 0, NSScreen.main!.frame.size.width, NSScreen.main!.frame.size.height + 100)
//        let window = OverlayWindow()
//        window.setFrame(windowFrame, display: true)
//        window.styleMask = [.borderless];
//
//        let overlayView = ScreenshotOverlayView(frame: windowFrame)
//        
//        window.center()
//        window.backgroundColor = NSColor.clear
//        window.setFrameAutosaveName("overlay")
//        window.title = kAreaSelector
//        window.level = .screenSaver - 1
//        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
//        window.isOpaque = true
////        window.contentView = overlayView
//        window.contentView?.addSubview(overlayView)
//        
//        self.init(window: window)
//    }
//
//    override func showWindow(_ sender: Any?) {
//        super.showWindow(sender)
//    }
//    
//    override func windowDidLoad() {
//        super.windowDidLoad()
//        
//        self.window!.toggleFullScreen(nil)
//    }
//}
