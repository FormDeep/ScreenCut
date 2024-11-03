//
//  TranslatorView.swift
//  ScreenCut
//
//  Created by helinyu on 2024/11/2.
//

import SwiftUI

class OCRViewWindowController : NSWindowController {
    var cuText: String?
    
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
        window.setFrameAutosaveName("OCR")
        window.title = "OCR"
        window.level = .screenSaver
        window.contentView = NSHostingView(rootView: OCRView(resultText: transText))
        self.init(window: window)
        
        cuText = transText
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        self.windowDidLoad()
    }
    
    override func windowDidLoad() {
           super.windowDidLoad()
        print("window windowDidLoad 执行了")
        
        // 设置工具栏
//           if let window = self.window {
//               let toolbar = NSToolbar(identifier: "MyToolbar")
//               toolbar.delegate = self
//               window.toolbar = toolbar
//           }
           
        let button = NSButton(title: "翻译", target: self, action: #selector(buttonClicked))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.bezelStyle = .rounded // 设置按钮样式
        button.wantsLayer = true
        button.layer?.cornerRadius = 5 // 设置圆角

        // 确保有有效的内容视图
        guard let contentView = window?.contentView else {
            print("没有contentView")
            return
        }

        // 添加按钮到内容视图
        contentView.addSubview(button)

        // 设置按钮的约束，使其在右上角
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -20),
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20)
        ])

       }

       @objc func buttonClicked() {
           print("按钮被点击了")
           ScreenCut.transforRequest(self.cuText ?? "") { result, flag in
               let text = flag ? result: "翻译失败"
               DispatchQueue.main.async {
                   TranslatorViewWindowController(transText: text).showWindow(nil)
               }
           }
       }
}

extension NSToolbarItem.Identifier {
    static let addItem = NSToolbarItem.Identifier("AddItem")
    static let removeItem = NSToolbarItem.Identifier("RemoveItem")
}

extension OCRViewWindowController: NSToolbarDelegate {
    
    @objc func addItem() {
        print("添加项目")
    }

    @objc func removeItem() {
        print("移除项目")
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.addItem, .removeItem]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.addItem, .removeItem]
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .addItem:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "Add"
            item.target = self
            item.action = #selector(addItem)
            return item
            
        case .removeItem:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "Remove"
            item.target = self
            item.action = #selector(removeItem)
            return item
            
        default:
            return nil
        }
    }
}


struct OCRView: View {
    var resultText: String?
    var body: some View {
        Text(resultText ?? "没有文字内容")
            .padding(.top, 40)
    }
}

#Preview {
    OCRView()
}
