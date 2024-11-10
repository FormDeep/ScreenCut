//
//  ToastWindow.swift
//  ScreenCut
//
//  Created by helinyu on 2024/11/10.
//

import SwiftUI
import Cocoa

class ToastWindow: NSWindow {
    init(message: String) {
        
        let toastHeight: CGFloat = 50
        let toastWidth: CGFloat = 300
        
        // 设置 Toast Window 的大小和位置
        let screenSize = NSScreen.main?.frame.size ?? CGSize(width: 800, height: 600)
        let toastPosition = CGPoint(x: (screenSize.width - toastWidth) / 2, y: screenSize.height - toastHeight - 100)
        
        // 创建一个无边框、透明的窗口
        let styleMask: NSWindow.StyleMask = [.borderless, .nonactivatingPanel]
        super.init(contentRect: NSRect(x: toastPosition.x, y: toastPosition.y, width: toastWidth, height: toastHeight),
                   styleMask: styleMask,
                   backing: .buffered,
                   defer: false)
        
        self.isOpaque = false
        self.backgroundColor = NSColor.black.withAlphaComponent(0.8)
        self.level = .screenSaver + 1
        self.hasShadow = true
        self.isReleasedWhenClosed = false
        self.isMovableByWindowBackground = false
        
        // 创建并设置显示的文本
        let textLabel = NSTextField(labelWithString: message)
        textLabel.font = NSFont.systemFont(ofSize: 14)
        textLabel.textColor = .white
        textLabel.alignment = .center
        textLabel.frame = NSRect(x: 10, y: 10, width: toastWidth - 20, height: toastHeight - 20)
        
        // 添加文本标签到窗口的内容视图
        self.contentView?.addSubview(textLabel)
    }
    
    func showToast() {
        DispatchQueue.main.async {
            self.makeKeyAndOrderFront(nil)
            
            // 自动隐藏 Toast，延迟 2 秒
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.close()
            }
        }
    }
}

