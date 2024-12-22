//
//import Cocoa
//import ScreenCaptureKit
//import AVFoundation
//
//class ScreenRecorder: NSObject, SCStreamDelegate, SCStreamOutput {
//    
//    private var captureStream: SCStream?
//    private var videoWriter: AVAssetWriter?
//    private var videoWriterInput: AVAssetWriterInput?
//    private var videoWriterAdaptor: AVAssetWriterInputPixelBufferAdaptor?
//    private var recordingQueue = DispatchQueue(label: "com.example.screenRecorder")
//    private var isRecording = false
//    
//    func startRecording(outputURL: URL) {
//        let content = ScreenCut.availableContent
//        let display = content!.displays[1]
////        guard  else {
////            print("No available displays to capture")
////            return
////        }
//        
//        // Configure SCStream
//        let contentFilter = SCContentFilter(display: display, excludingWindows: [])
//        let configuration = SCStreamConfiguration()
//        configuration.width = display.width
//        configuration.height = display.height
//        configuration.pixelFormat = kCVPixelFormatType_32BGRA
//        configuration.minimumFrameInterval = CMTimeMake(value: 1, timescale: 30) // 30 FPS
//        
//        // Initialize video writer
//        do {
//            videoWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
//            let videoSettings: [String: Any] = [
//                AVVideoCodecKey: AVVideoCodecType.h264,
//                AVVideoWidthKey: display.width,
//                AVVideoHeightKey: display.height
//            ]
//            videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
//            videoWriterInput?.expectsMediaDataInRealTime = true
//            
//            guard let videoWriterInput = videoWriterInput else { return }
//            
//            videoWriterAdaptor = AVAssetWriterInputPixelBufferAdaptor(
//                assetWriterInput: videoWriterInput,
//                sourcePixelBufferAttributes: [
//                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
//                    kCVPixelBufferWidthKey as String: display.width,
//                    kCVPixelBufferHeightKey as String: display.height
//                ]
//            )
//            
//            videoWriter?.add(videoWriterInput)
//            videoWriter?.startWriting()
//            videoWriter?.startSession(atSourceTime: .zero)
//        } catch {
//            print("Failed to initialize video writer: \(error.localizedDescription)")
//            return
//        }
//        
//        // Start capturing
//        do {
//            captureStream = SCStream(filter: contentFilter, configuration: configuration, delegate: self)
//            try captureStream?.addStreamOutput(self, type: .screen, sampleHandlerQueue: recordingQueue)
//            try captureStream?.startCapture()
//            isRecording = true
//            print("Recording started")
//        } catch {
//            print("Failed to start screen capture: \(error.localizedDescription)")
//        }
//    }
//    
//    func stopRecording() {
//        guard isRecording else { return }
//        isRecording = false
//        
//        // Stop capture stream
//        captureStream?.stopCapture()
//        
//        // Finish writing video
//        videoWriterInput?.markAsFinished()
//        videoWriter?.finishWriting {
//            print(
//                "Recording finished. File saved at: \(self.videoWriter?.outputURL.path ?? "unknown location")"
//            )
//        }
//    }
//    
//    // MARK: - SCStreamOutput
//    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
//        if type == .screen {  // Ensure we're processing the screen capture data
//            print("Received screen sample buffer \(sampleBuffer) \(type) \(stream)")
//            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//            let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
//            videoWriterAdaptor?.append(pixelBuffer, withPresentationTime: presentationTime)
//        }
//    }
//    
//        //这个dialing方法没有走
//        func stream(_ stream: SCStream, didStopWithError error: any Error) {
//            print("lt -- didStopWithError")
//        }
//    
//        func outputVideoEffectDidStop(for stream: SCStream) {
//            print("lt -- outputVideoEffectDidStop")
//        }
//    
//        func outputVideoEffectDidStart(for stream: SCStream) {
//            print("lt -- outputVideoEffectDidStart")
//        }
//}

//
//import Cocoa
//import ScreenCaptureKit
//import AVFoundation
//
//class ScreenRecorder: NSObject, SCStreamDelegate, SCStreamOutput {
//
//    private var captureStream: SCStream?
//    private var videoWriter: AVAssetWriter?
//    private var videoWriterInput: AVAssetWriterInput?
//    private var videoWriterAdaptor: AVAssetWriterInputPixelBufferAdaptor?
//    private var isRecording = false
//
//    func startRecording(outputURL: URL) async {
//        var content: SCShareableContent?
//        do {
//            content  = try await SCShareableContent.current
//        }
//        catch {
//            print("Failed to content: \(error.localizedDescription)")
//            return
//        }
//       
//        guard let display = content!.displays.first else {
//            print("No available displays to capture.")
//            return
//        }
//
//        let contentFilter = SCContentFilter(display: display, excludingWindows: [])
//        let configuration = SCStreamConfiguration()
//        configuration.width = display.width
//        configuration.height = display.height
//        configuration.pixelFormat = kCVPixelFormatType_32BGRA
//        configuration.minimumFrameInterval = CMTimeMake(value: 1, timescale: 30) // 30 FPS
//
//        do {
//            videoWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
//            let videoSettings: [String: Any] = [
//                AVVideoCodecKey: AVVideoCodecType.h264,
//                AVVideoWidthKey: display.width,
//                AVVideoHeightKey: display.height
//            ]
//            videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
//            videoWriterInput?.expectsMediaDataInRealTime = true
//
//            guard let videoWriterInput = videoWriterInput else { return }
//            videoWriterAdaptor = AVAssetWriterInputPixelBufferAdaptor(
//                assetWriterInput: videoWriterInput,
//                sourcePixelBufferAttributes: [
//                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
//                    kCVPixelBufferWidthKey as String: display.width,
//                    kCVPixelBufferHeightKey as String: display.height
//                ]
//            )
//
//            videoWriter?.add(videoWriterInput)
//            videoWriter?.startWriting()
//            videoWriter?.startSession(atSourceTime: .zero)
//
//            captureStream = SCStream(filter: contentFilter, configuration: configuration, delegate: self)
//            try captureStream?.addStreamOutput(self, type: .screen, sampleHandlerQueue: DispatchQueue(label: "com.example.screenRecorder"))
//            try await captureStream?.startCapture()
//            isRecording = true
//            print("Recording started")
//        } catch {
//            print("Failed to start recording: \(error.localizedDescription)")
//        }
//    }
//
//    func stopRecording() {
//        guard isRecording else { return }
//        isRecording = false
//
//        captureStream?.stopCapture()
//        videoWriterInput?.markAsFinished()
//        videoWriter?.finishWriting {
//            print(
//                "Recording finished. File saved at: \(self.videoWriter?.outputURL.path ?? "unknown location")"
//            )
//        }
//    }
//
//    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
//        guard type == .screen else { return }
//
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
//              let videoWriterAdaptor = videoWriterAdaptor,
//              videoWriterInput?.isReadyForMoreMediaData == true else {
//            print("Warning: Failed to process sample buffer.")
//            return
//        }
//
//        let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
//        if !videoWriterAdaptor.append(pixelBuffer, withPresentationTime: presentationTime) {
//            print("Error: Failed to append pixel buffer.")
//        } else {
//            print("Frame appended at time: \(presentationTime.seconds)")
//        }
//    }
//}


import Cocoa
import ScreenCaptureKit
import AVFoundation

class ScreenRecorder: NSObject, SCStreamDelegate, SCStreamOutput {
    private var captureStream: SCStream?
    private var videoWriter: AVAssetWriter?
    private var videoWriterInput: AVAssetWriterInput?
    private var videoWriterAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var isRecording = false

    func startRecording(outputURL: URL) async {
        var content: SCShareableContent?
        do {
            content  = try await SCShareableContent.current
        }
        catch {
            print("Failed to content: \(error.localizedDescription)")
            return
        }
        
        guard let display = content!.displays.first else {
            print("No available displays to capture.")
            return
        }

        let contentFilter = SCContentFilter(display: display, excludingWindows: [])
        let configuration = SCStreamConfiguration()
        configuration.width = display.width
        configuration.height = display.height
        configuration.pixelFormat = kCVPixelFormatType_32BGRA
        configuration.minimumFrameInterval = CMTimeMake(value: 1, timescale: 30) // 30 FPS

        do {
            videoWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: display.width,
                AVVideoHeightKey: display.height
            ]
            videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            videoWriterInput?.expectsMediaDataInRealTime = true

            guard let videoWriterInput = videoWriterInput else { return }
            videoWriterAdaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: videoWriterInput,
                sourcePixelBufferAttributes: [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                    kCVPixelBufferWidthKey as String: display.width,
                    kCVPixelBufferHeightKey as String: display.height
                ]
            )

            videoWriter?.add(videoWriterInput)
            videoWriter?.startWriting()
            videoWriter?.startSession(atSourceTime: .zero)

            captureStream = SCStream(filter: contentFilter, configuration: configuration, delegate: self)
            try captureStream?.addStreamOutput(self, type: .screen, sampleHandlerQueue: DispatchQueue(label: "com.example.screenRecorder"))
            try await captureStream?.startCapture()
            isRecording = true
            print("Recording started")
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        guard isRecording else { return }
        isRecording = false

        captureStream?.stopCapture()
        videoWriterInput?.markAsFinished()
        videoWriter?.finishWriting {
            print(
                "Recording finished. File saved at: \(self.videoWriter?.outputURL.path ?? "unknown location")"
            )
        }
    }

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .screen else {
            print("Error: Received unsupported sample buffer type.")
            return
        }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Error: CMSampleBuffer does not contain a valid image buffer.")
            return
        }

        guard let videoWriterAdaptor = videoWriterAdaptor,
              videoWriterInput?.isReadyForMoreMediaData == true else {
            print("Warning: Video writer is not ready for more data.")
            return
        }

        let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        if !videoWriterAdaptor.append(pixelBuffer, withPresentationTime: presentationTime) {
            print("Error: Failed to append pixel buffer.")
        } else {
            print("Frame appended at time: \(presentationTime.seconds)")
        }
    }
}
