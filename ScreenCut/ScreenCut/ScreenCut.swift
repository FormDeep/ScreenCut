import ScreenCaptureKit
import Cocoa
import FileKit
import SwiftUI

class ScreenCut {
    
    static var availableContent: SCShareableContent?
    static var screenArea: NSRect?
    
    func closeAllWindow(except: String = "") {
        for w in NSApp.windows.filter({
            $0.title != "Item-0" && $0.title != ""
            && !$0.title.lowercased().contains(".qma")
            && !$0.title.contains(except) }) { w.close() }
    }
    
    static func getScreenWithMouse() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        let screenWithMouse = NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, false) })
        return screenWithMouse
    }
    
    func createNewWindow(view: some View, title: String, random: Bool = false) {
        guard let screen = ScreenCut.getScreenWithMouse() else { return }
        closeAllWindow()
        var seed = 0.0
        if random { seed = CGFloat(Int(arc4random_uniform(401)) - 200) }
        let wX = (screen.frame.width - 780) / 2 + seed + screen.frame.minX
        let wY = (screen.frame.height - 555) / 2 + 100 + seed + screen.frame.minY
        let contentView = NSHostingView(rootView: view)
        contentView.frame = NSRect(x: wX, y: wY, width: 780, height: 555)
        let window = NSWindow(contentRect: contentView.frame, styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
        window.title = title
        window.contentView = contentView
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(self)
        window.orderFrontRegardless()
    }
    
    static  func updateScreenContent() async {
        SCShareableContent.getExcludingDesktopWindows(false, onScreenWindowsOnly: false) { content, error in
            if let error = error {
                switch error {
                case SCStreamError.userDeclined: Auth.requestPermissions()
                default: print("Error: failed to fetch available content: ", error.localizedDescription)
                }
                return
            }
            
            ScreenCut.availableContent = content
//            self.saveImage(content)
        }
    }
    
    @MainActor static func saveScreenFullImage() {
        let content = ScreenCut.availableContent
        guard let displays = content?.displays else {
            return
        }
        let display: SCDisplay = displays.first!
        let contentFilter = SCContentFilter(display: display, excludingWindows: [])
        let configuration = SCStreamConfiguration()
        configuration.width = display.width
        configuration.height = display.height
        SCScreenshotManager.captureImage(contentFilter: contentFilter, configuration: configuration) { image, error in
            print("lt -- image : eror : %@", error.debugDescription)
            guard let img = image else {
                print(" : %@", error.debugDescription)
                return
            }
            ScreenCut.saveImageToFile(img)
        }
    }

    @MainActor static func saveImageToFile(_ image: CGImage) {
        let imgName = Date.getNameByDate()
        let curPath = "file://" + VarExtension.createTargetDirIfNotExit() + "/" + imgName + ".png"
        let destinationURL: CFURL = URL(string: curPath)! as CFURL
        let destination = CGImageDestinationCreateWithURL(destinationURL, kUTTypePNG, 1, nil)
        guard let destination = destination else {
            print("保存路径没有创建成功")
            return
        }
        CGImageDestinationAddImage(destination, image, nil)
        
        if CGImageDestinationFinalize(destination) {
            print("保存成功路径: \(destinationURL)")
        } else {
            print("保存失败")
        }
    }
}




