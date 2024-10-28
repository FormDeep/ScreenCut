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

let kAreaWith:String = "areaWidth"
let kAreaHeight:String = "areaHeight"
let kHighRes: String = "highRes"

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
            await  ScreenCut.updateScreenContent()
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

struct AreaSelector: View {
    @State private var isPopoverShowing = false
    @State private var resizePopoverShowing = false
    @State private var autoStop = 0
    
    var screen: SCDisplay!
    var appDelegate = AppDelegate.shared
    
    var body: some View {
        ZStack {
            Color(nsColor: NSColor.windowBackgroundColor)
                .cornerRadius(10)
            VStack {
                HStack(spacing: 4) {
                    Spacer()
                    Button(action: {
                        resizePopoverShowing = true
                    }, label: {
                        VStack{
                            Image(systemName: "viewfinder.circle.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(.blue)
                            Text("Resize")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 12))
                        }
                    })
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        AreaSelector.cutImage()
                    }, label: {
                        VStack{
                            Image(systemName: "record.circle.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(.red)
                            Text("Start")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 12))
                        }
                    }).buttonStyle(.plain)
                    Spacer()
                }
            }
            Button(action: {
                for w in NSApplication.shared.windows.filter({ $0.title == kAreaSelector || $0.title == "Start Recording" || $0.title == "编辑图片"}) { w.close() }
                AppDelegate.stopGlobalMouseMonitor()
            }, label: {
                Image(systemName: "x.circle")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.secondary)
            })
            .buttonStyle(.plain)
            .padding(.leading, -354).padding(.top, -39)
        }.frame(width: 720, height: 90).hidden()
    }
    
    static func cutImage() {
        guard let displays = ScreenCut.availableContent?.displays else {
            return
        }
        let display: SCDisplay = displays.first!
        let contentFilter = SCContentFilter(display: display, excludingWindows: [])
        let configuration = SCStreamConfiguration()
        
        // 翻转 Y 坐标
        let flippedY = CGFloat(display.height) - ScreenCut.screenArea!.origin.y - ScreenCut.screenArea!.size.height
        configuration.sourceRect = CGRectMake( ScreenCut.screenArea!.origin.x, flippedY, ScreenCut.screenArea!.size.width, ScreenCut.screenArea!.size.height)
        configuration.destinationRect = CGRectMake( ScreenCut.screenArea!.origin.x, flippedY, ScreenCut.screenArea!.size.width, ScreenCut.screenArea!.size.height)
        
        SCScreenshotManager.captureImage(contentFilter: contentFilter, configuration: configuration) { image, error in
            print("lt -- image : eror : %@", error.debugDescription)
            guard let img = image else {
                print(" : %@", error.debugDescription)
                return
            }
            ScreenCut.saveImageToFile(img)
        }
    }
}
