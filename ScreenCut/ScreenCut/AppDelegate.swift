//
//  AreaSelector.swift
//  VCB
//
//  Created by helinyu on 2024/10/23.
//


import Foundation
import SwiftUI
import ScreenCaptureKit
import AppKit
import KeyboardShortcuts

let mousePointer = NSWindow(contentRect: NSRect(x: -70, y: -70, width: 70, height: 70), styleMask: [.borderless], backing: .buffered, defer: false)
var keyMonitor: Any? // key监视器
var mouseMonitor: Any? // 鼠标监视器

extension NSScreen {
    var displayID: CGDirectDisplayID? {
        return deviceDescription[NSDeviceDescriptionKey(rawValue: "NSScreenNumber")] as? CGDirectDisplayID
    }
}

extension SCDisplay {
    var nsScreen: NSScreen? {
        return NSScreen.screens.first(where: { $0.displayID == self.displayID })
    }
}

class AppDelegate : NSObject, NSApplicationDelegate {
    var isResizing = false
    static let shared = AppDelegate()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        Task {
            await ScreenCut.updateScreenContent()
        }
        
        KeyboardShortcuts.onKeyDown(for: .selectedAreaCut) {[self] in
            ScreenshotWindow().makeKeyAndOrderFront(nil)
        }
    }

    
    //     停止鼠标检测器
    static func stopGlobalMouseMonitor() {
        mousePointer.orderOut(nil)
        if let monitor = mouseMonitor { NSEvent.removeMonitor(monitor); mouseMonitor = nil }
    }
    
    static func getSCDisplayWithMouse() -> SCDisplay? {
        if let displays = ScreenCut.availableContent?.displays {
            for display in displays {
                if let currentDisplayID = ScreenCut.getScreenWithMouse()?.displayID {
                    if display.displayID == currentDisplayID {
                        return display
                    }
                }
            }
        }
        return nil
    }
    
}
