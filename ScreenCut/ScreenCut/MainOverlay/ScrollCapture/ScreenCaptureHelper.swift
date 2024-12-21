//
//  ScreenCaptureHelper.swift
//  ScreenCut
//
//  Created by waaw on 21/12/2024.
//

import Cocoa
import ScreenCaptureKit

// 

class ScreenCaptureHelper: NSObject, SCStreamDelegate, SCStreamOutput {
    
    private var captureStream: SCStream?
    private var capturedImages: [NSImage] = []
    private var scrollHeight: CGFloat = 0
    private var screenWidth: CGFloat = 0
    private var scrollPosition: CGFloat = 0
    private var screenHeight: CGFloat = 0
    
    func startCapturing(scrollHeight: CGFloat, screenWidth: CGFloat, screenHeight: CGFloat) {
        self.scrollHeight = scrollHeight
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
        self.scrollPosition = 0
        self.capturedImages.removeAll()
        
        captureScreen()
    }
    
    private func captureScreen() {
        
        
        let content = ScreenCut.availableContent
        guard let displays = content?.displays else {
            return
        }
        
//        let display: SCDisplay = findCurrentScreen(
//            id: AppDelegate.shared.screentId!,
//            displays: displays
//        )!
        let display = content?.displays.first!
        let contentFilter = SCContentFilter(display: display!, excludingWindows: [])
        let configuration = SCStreamConfiguration()
        configuration.width = display!.width
        configuration.height = display!.height
        
        captureStream = SCStream(
            filter: contentFilter,
            configuration: configuration,
            delegate: self
        )
        
        // 启动捕获
        do {
            try captureStream?.addStreamOutput(self, type: .screen, sampleHandlerQueue: DispatchQueue.main)
            try captureStream?.startCapture()
            print("Started screen capture")
        } catch {
            print("Failed to start screen capture: \(error.localizedDescription)")
        }
    }
    
    // MARK: - SCStreamDelegate
    func stream(_ stream: SCStream, didStopWithError error: any Error) {
        print("lt -- didStopWithError")
    }

    /**
     @abstract outputVideoEffectDidStartForStream:
     @param stream the SCStream object
     @discussion notifies the delegate that the stream's overlay video effect has started.
    */
    @available(macOS 14.0, *)
    func outputVideoEffectDidStart(for stream: SCStream) {
        print("lt -- outputVideoEffectDidStart")
    }

    /**
     @abstract stream:outputVideoEffectDidStart:
     @param stream the SCStream object
     @discussion notifies the delegate that the stream's overlay video  effect has stopped.
    */
    func outputVideoEffectDidStop(for stream: SCStream) {
        print("lt -- outputVideoEffectDidStop")
    }
    
    //     protocol
    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        print("lt -- didOutputSampleBuffer")
        // 将 sampleBuffer 转换为 NSImage
        if let capturedImageRef = imageFromSampleBuffer(sampleBuffer) {
            let capturedImage = NSImage(cgImage: capturedImageRef, size: .zero)
            capturedImages.append(capturedImage)
        }
        
        scrollPosition += scrollHeight
        if scrollPosition < screenHeight {
            scrollDown()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.captureScreen()
            }
        } else {
            createFinalImage()
        }
    }
    
    private func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> CGImage? {
        // 从 CMSampleBuffer 中提取出图像
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let context = CIContext()
        return context.createCGImage(ciImage, from: ciImage.extent)
    }
    
    private func scrollDown() {
        // 使用 CGEvent 模拟滚动
        if let scrollEvent = CGEvent.init(
            scrollWheelEvent2Source: nil,
            units: .line,
            wheelCount: 1,
            wheel1: -2,
            wheel2: 0,
            wheel3: 0
        ) {
            scrollEvent.post(tap: .cghidEventTap)
        }
    }
    
    private func createFinalImage() {
        guard let finalImage = concatenateImages(capturedImages) else { return }
        saveImage(finalImage)
    }
    
    private func concatenateImages(_ images: [NSImage]) -> NSImage? {
        guard !images.isEmpty else { return nil }
        
        let totalHeight = images.reduce(0) { $0 + $1.size.height }
        let width = images.first?.size.width ?? 0
        
        let finalImage = NSImage(size: NSSize(width: width, height: totalHeight))
        finalImage.lockFocus()
        
        var yOffset: CGFloat = 0
        for image in images {
            image.draw(in: NSRect(x: 0, y: yOffset, width: width, height: image.size.height))
            yOffset += image.size.height
        }
        
        finalImage.unlockFocus()
        return finalImage
    }
    
    private func saveImage(_ image: NSImage) {
        guard let imageData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: imageData) else { return }
        
        let pngData = bitmapRep.representation(using: .png, properties: [:])
        
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["png"]
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    try pngData?.write(to: url, options: .atomic)
                    print("Image saved to \(url)")
                } catch {
                    print("Error saving file: \(error.localizedDescription)")
                }
            }
        }
    }
}
