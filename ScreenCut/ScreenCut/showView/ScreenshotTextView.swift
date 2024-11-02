import Foundation
import SwiftUI
import ScreenCaptureKit
import AppKit

// 文本内容
class ScreenshotTextView: NSView , NSTextViewDelegate, OverlayProtocol{
    var maxFrame: NSRect?
    var size: NSSize
    var fillOverLayeralpha: CGFloat = 0.0 // 默认值
    var editFinished = false;
    var selectedColor: NSColor = NSColor.white
    var lineWidth: CGFloat = 4.0
    var textView: NSTextView = NSTextView(frame: NSMakeRect(0, 0, 0, 0))
    var hasRelease = false
    var textIsEditing = false
    
    init(frame: CGRect, size: NSSize) {
        self.size = size
        super.init(frame: frame)
        self.textView.backgroundColor = .clear
        self.addSubview(self.textView)
        NotificationCenter.default.addObserver(self, selector: #selector(onChangeFont), name: Notification.Name("text.size.font.change"), object: "")
        NotificationCenter.default.addObserver(self, selector: #selector(onChangeColor), name: Notification.Name("text.color.change"), object: "")
    }
    
    @objc func onChangeFont(noti: Notification) {
        if (textIsEditing) {
            self.textView.font = .systemFont(ofSize: CGFloat(EditCutBottomShareModel.shared.lineSize))
            self.textView.frame.size = CGSizeMake(CGFloat(EditCutBottomShareModel.shared.lineSize) * 6, CGFloat(EditCutBottomShareModel.shared.lineSize) + 6)
        }
    }
    
    @objc func onChangeColor(noti: Notification) {
        if (textIsEditing) {
            self.textView.textColor = EditCutBottomShareModel.shared.selectColor.nsColor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
    }

    func textShouldEndEditing(_ textObject: NSText) -> Bool {
        return true
    }
    
    func textDidBeginEditing(_ notification: Notification) {
        self.textIsEditing = true
    }
    
    func textDidEndEditing(_ notification: Notification) {
        print("textDidEndEditing")
        self.textIsEditing = false
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        if (self.textView.frame.size.width <= 1.0) {
            self.textView.frame = NSMakeRect(location.x, location.y, CGFloat(EditCutBottomShareModel.shared.lineSize) * 6, CGFloat(EditCutBottomShareModel.shared.lineSize) + 6)
            self.textView.delegate = self;
            self.window?.makeFirstResponder(self.textView)
            self.textView.font = .systemFont(ofSize: CGFloat(EditCutBottomShareModel.shared.lineSize))
            self.textView.textColor = EditCutBottomShareModel.shared.selectColor.nsColor
            self.textView.layer?.cornerRadius = 4.0
            self.textView.wantsLayer = true
            self.textView.layer?.borderWidth = 2.0
            self.textView.layer?.borderColor = NSColor.gray.cgColor
            self.textView.layer?.masksToBounds = true
        }
        else {
            self.window?.makeFirstResponder(nil)
            print("lt -- 点击显示: \(self.textView.string.count)")
            if self.textView.string.count == 0 {
                self.textView.frame = NSRect.zero
            }else {
                if !self.hasRelease {
                    self.hasRelease = true
                    self.addSubviewFromSuperView()
                }
            }
            
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        print("lt -- subview mosueup")
    }
    
    func addSubviewFromSuperView() {
        self.editFinished = true
        let superView: ScreenshotOverlayView = self.superview as! ScreenshotOverlayView
        superView.addCustomSubviews()
    }
}


