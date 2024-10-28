//
//  ScreenCutApp.swift
//  ScreenCut
//
//  Created by helinyu on 2024/10/25.
//

import SwiftUI
import AppKit

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
            .keyboardShortcut("c", modifiers: [.control])
            .padding()
            Button("选择截屏") {
                let screenshotWindow = ScreenshotWindow()
                screenshotWindow.makeKeyAndOrderFront(nil)

            }
            .keyboardShortcut("x", modifiers: [.control])
            .padding()
            Divider()
            Button("偏好设置") {
                let aboutWindowController = PreferenceSettingsViewController()
                aboutWindowController.showWindow(nil)
            }
            .padding()
            Button("关于") {
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
