//
//  TranslatorView.swift
//  ScreenCut
//
//  Created by helinyu on 2024/11/2.
//

import SwiftUI

class TranslatorViewWindowController : NSWindowController {
    
    convenience init(transText: String?) {
        let originX = NSScreen.main!.frame.size.width/2 - 270
        let originY = NSScreen.main!.frame.size.height/2 - 200
        let window = NSWindow(
            contentRect: NSRect(x: originX, y: originY, width: 540, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.center()
        window.setFrameAutosaveName("翻译")
        window.title = "翻译"
        window.level = .screenSaver
        window.contentView = NSHostingView(rootView: OCRView(resultText: transText))
        
        self.init(window: window)
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
    }
}

struct TranslatorView: View {
    var resultText: String?
    var body: some View {
        Text(resultText ?? "没有文字内容")
    }
}

#Preview {
    OCRView()
}
