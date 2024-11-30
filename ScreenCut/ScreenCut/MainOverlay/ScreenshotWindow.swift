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
        super.init(contentRect: contentRect, styleMask: [  .closable, .borderless], backing: bufferingType, defer: flag)
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
