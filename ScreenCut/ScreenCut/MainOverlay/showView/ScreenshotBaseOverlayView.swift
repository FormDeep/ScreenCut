//
//  ScreenshotBaseOverlayView.swift
//  ScreenCut
//
//  Created by helinyu on 2024/11/3.
//

import Foundation
import AppKit


class ScreenshotBaseOverlayView: NSView, OverlayProtocol {
    var selectedColor: NSColor = .white
    var lineWidth: CGFloat = 2.0
    var editFinished = false;
    
    func handleborderForPoint(_ point: NSPoint) -> RetangleResizeHandle {
        return .none
    }
    
    func isOnBorderAt(_ point: NSPoint) -> Bool {
        let handle = self.handleborderForPoint(point)
        if handle == .none {
            return false
        }
        return true
    }
    
    func handleForPoint(_ point: NSPoint) -> RetangleResizeHandle {
        return .none
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



