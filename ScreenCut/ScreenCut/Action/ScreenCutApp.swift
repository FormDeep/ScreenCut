//
//  ScreenCutApp.swift
//  ScreenCut
//
//  Created by helinyu on 2024/10/25.
//

import SwiftUI
import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let selectedAreaCut = Self("selectedAreaCut")
    static let fullScreenCut = Self("fullScreenCut")
}

@main
struct ScreenCutApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // 设置激活策略为 accessory
        NSApplication.shared.setActivationPolicy(.accessory)
    }
    
    var body: some Scene {
//         直接使用MenuBar 替代掉主窗口
        MenuBarExtra("", systemImage: "scissors"){
            Button("截屏") {
                ScreenCut.saveScreenFullImage()
            }
            .padding()
            Button("选择截屏") {
//                print("lt -- 设置鼠标样式 按钮样式")
                NSCursor.crosshair.set()
                let rootW = ScreenshotWindow()
                rootW.makeKeyAndOrderFront(nil)
            }
            Divider()
            Button("偏好设置") {
                let aboutWindowController = PreferenceSettingsViewController()
                aboutWindowController.showWindow(nil)
            }
            .padding()
            Button("关于"){
                let aboutWindowController = AboutWindowController()
                aboutWindowController.showWindow(nil)
            }
            .padding()
            Divider()
            Button("退出") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("Q", modifiers: [.command])
        }
        
    }
}

extension Scene {
    func myWindowIsContentResizable() -> some Scene {
        if #available(macOS 13.0, *) {
            return self.windowResizability(.contentSize)
        }
        else {
            return self
        }
    }
}
