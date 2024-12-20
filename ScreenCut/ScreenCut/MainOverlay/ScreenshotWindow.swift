//
//  ScreenshotWindow.swift
//  ScreenCut
//
//  Created by helinyu on 2024/11/3.
//

import Foundation
import AppKit

func findCurrentScreen() -> CGDirectDisplayID? {
    let mouseLocation = NSEvent.mouseLocation
    let screens = NSScreen.screens
    for screen in screens {
        let screenFrame = screen.frame
        if screenFrame.contains(mouseLocation) {
            let description = screen.deviceDescription
            print("Mouse is on screen with ID: \(description)")
            return screen.displayID
        }
    }
    return nil
}


class ScreenshotWindow: NSWindow {
    
    var parentView:ScreenshotOverlayView?
    
    init(_ contentRect: NSRect = NSScreen.main!.frame, backing bufferingType: NSWindow.BackingStoreType = .buffered, defer flag: Bool = false, size: NSSize = NSSize.zero) {
        super.init(contentRect: contentRect, styleMask: [  .closable, .borderless], backing: bufferingType, defer: flag)
        let rect = NSRect(x: 0, y: 0, width: contentRect.size.width, height: contentRect.size.height)
        print("lt --- content Rect : \(contentRect) --- rect : \(rect)")
        AppDelegate.shared.screentId = findCurrentScreen()
        let overlayView = ScreenshotOverlayView(frame: rect)
        self.isOpaque = false
        self.hasShadow = false
        self.level = .screenSaver - 1
        self.title = kAreaSelector
        self.backgroundColor = NSColor.clear
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isReleasedWhenClosed = false
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
