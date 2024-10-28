//
//  ScreenshotWindow.swift
//  TestMap
//
//  Created by helinyu on 2024/10/26.
//

import Foundation
import AppKit

// 使用NSPanel报错，会出现不弹出来的问题，以后少用子类处理
class ScreenshotWindow: NSWindow {
    
    var parentView:ScreenshotOverlayView?
    
    init(_ contentRect: NSRect = NSScreen.main!.frame, backing bufferingType: NSWindow.BackingStoreType = .buffered, defer flag: Bool = false, size: NSSize = NSSize.zero) {
        let overlayView = ScreenshotOverlayView(frame: contentRect, size:size)
        super.init(contentRect: contentRect, styleMask: [  .closable, .borderless,.resizable], backing: bufferingType, defer: flag)
        self.isOpaque = false
        self.hasShadow = false
        self.level = .popUpMenu
        self.title = kAreaSelector
        self.backgroundColor = NSColor.clear
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isReleasedWhenClosed = false
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
