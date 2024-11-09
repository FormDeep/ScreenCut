//
//  Toast.swift
//  ScreenCut
//
//  Created by helinyu on 2024/11/9.
//

import Cocoa

class Toast: NSView {
    
    // 初始化 Toast 标签
    private let textLabel = NSTextField()
    
    init(message: String) {
        super.init(frame: .zero)
        
        // 设置文字标签的属性
        textLabel.stringValue = message
        textLabel.isEditable = false
        textLabel.isBezeled = false
        textLabel.drawsBackground = false
        textLabel.textColor = .white
        textLabel.alignment = .center
        textLabel.font = NSFont.systemFont(ofSize: 14)
        
        // 设置 Toast 背景样式
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.8).cgColor
        layer?.cornerRadius = 8
        
        addSubview(textLabel)
        
        // 设置自动布局
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 显示 Toast
    func show(in parentView: NSView, duration: TimeInterval = 2.0) {
        parentView.addSubview(self)
        
        // 设置 Toast 的位置和大小约束
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -50),
            widthAnchor.constraint(lessThanOrEqualToConstant: 200)
        ])
        
        // 初始透明度为 0，渐入显示
        alphaValue = 0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            animator().alphaValue = 1
        }
        
        // 在指定时间后淡出并移除
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                self.animator().alphaValue = 0
            }) {
                self.removeFromSuperview()
            }
        }
    }
}
