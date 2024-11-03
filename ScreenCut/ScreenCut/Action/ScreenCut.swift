import ScreenCaptureKit
import Cocoa
import FileKit
import SwiftUI
import Vision

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
            copyImageToPasteboard(img)
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

//    显示识别的内容
    static func showOCR() {
        guard let displays = ScreenCut.availableContent?.displays else {
            return
        }
        let display: SCDisplay = displays.first!
        let contentFilter = SCContentFilter(display: display, excludingWindows: [])
        let configuration = SCStreamConfiguration()
        
        // 翻转 Y 坐标
        let flippedY = CGFloat(display.height) - ScreenCut.screenArea!.origin.y - ScreenCut.screenArea!.size.height
        configuration.sourceRect = CGRectMake( ScreenCut.screenArea!.origin.x, flippedY, ScreenCut.screenArea!.size.width, ScreenCut.screenArea!.size.height)
        
        print("获取图片")
        SCScreenshotManager.captureImage(contentFilter: contentFilter, configuration: configuration) { image, error in
            print("lt -- image : eror : %@", error.debugDescription)
            guard let img = image else {
                print(" : %@", error.debugDescription)
                return
            }
            performOCR(img)
        }
    }
    
    static func performOCR(_ image: CGImage?) {
        guard let cgImage = image else {
            print("get image error ")
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let results = request.results as? [VNRecognizedTextObservation] else { return }
            var resultText = ""
            for observation in results {
                if let topCandidate = observation.topCandidates(1).first {
                    print("Recognized text: \(topCandidate.string)")
                    resultText += topCandidate.string
                    resultText += "\n"
                }
            }
            DispatchQueue.main.async {
                OCRViewWindowController(transText: resultText).showWindow(nil)
            }
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["zh-Hans"] // 支持简体中文
        
        let handler = VNImageRequestHandler(cgImage: cgImage , options: [:])
        try? handler.perform([request])
    }


   static  func copyImageToPasteboard(_ img: CGImage) {
       let image: NSImage = cgImageToNSImage(img)
       
       
        // 创建粘贴板
        let pasteboard = NSPasteboard.general
        
        // 清空当前粘贴板
        pasteboard.clearContents()
        
        // 将图片数据转换为 PNG 数据
        if let tiffData = image.tiffRepresentation,
           let bitmapRep = NSBitmapImageRep(data: tiffData),
           let pngData = bitmapRep.representation(using: .png, properties: [:]) {
            // 将 PNG 数据写入粘贴板
            pasteboard.setData(pngData, forType: .png)
        }
    }
    
    static func cgImageToNSImage(_ cgImage: CGImage) -> NSImage {
        // 创建 NSImage
        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        return nsImage
    }
    
//     识别并且翻译
    static func ocrThenTransRequest()  {
        guard let displays = ScreenCut.availableContent?.displays else {
            return
        }
        let display: SCDisplay = displays.first!
        let contentFilter = SCContentFilter(display: display, excludingWindows: [])
        let configuration = SCStreamConfiguration()
        
        // 翻转 Y 坐标
        let flippedY = CGFloat(display.height) - ScreenCut.screenArea!.origin.y - ScreenCut.screenArea!.size.height
        configuration.sourceRect = CGRectMake( ScreenCut.screenArea!.origin.x, flippedY, ScreenCut.screenArea!.size.width, ScreenCut.screenArea!.size.height)
        
        print("获取图片")
        SCScreenshotManager.captureImage(contentFilter: contentFilter, configuration: configuration) { image, error in
            print("lt -- image : eror : %@", error.debugDescription)
            guard let cgImage = image else {
                print("get image error ")
                return
            }
            
            let request = VNRecognizeTextRequest { request, error in
                guard let results = request.results as? [VNRecognizedTextObservation] else { return }
                var resultText = ""
                for observation in results {
                    if let topCandidate = observation.topCandidates(1).first {
                        print("Recognized text: \(topCandidate.string)")
                        resultText += topCandidate.string
                        resultText += "\n"
                    }
                }
                DispatchQueue.main.async {
                    self.transforRequest(resultText) { text, flag in
                        DispatchQueue.main.async {
                            TranslatorViewWindowController(transText: text).showWindow(nil)
                        }
                    }
                }
            }
            
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["zh-Hans"] // 支持简体中文
            
            let handler = VNImageRequestHandler(cgImage: cgImage , options: [:])
            try? handler.perform([request])
        }
    }
    
    static func transforRequest(_ text: String, then: @escaping (String?, Bool) -> Void)  {
        let urlString = "http://127.0.0.1:5000/translate" // 应该是本地没有解析localhost，要使用127.0.0.1
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = ["text": text] // 替换为你的参数
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error encoding parameters: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                    print("Response Dictionary: \(json)")
                    let translatedText:String = json["translated_text"] as! String
                    then(translatedText, true)

                } else {
                    print("Failed to convert data to dictionary")
                    then(nil, false)
                }
            } catch {
                print("Error parsing JSON: \(error)")
                then(nil, false)
            }
        }

        task.resume()
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
        
        SCScreenshotManager.captureImage(contentFilter: contentFilter, configuration: configuration) { image, error in
            print("lt -- image : eror : %@", error.debugDescription)
            guard let img = image else {
                print(" : %@", error.debugDescription)
                return
            }
            ScreenCut.copyImageToPasteboard(img)
            ScreenCut.saveImageToFile(img)
        }
    }

}




