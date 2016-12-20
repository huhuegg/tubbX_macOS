//
//  MNScreenRecorder.swift
//  eduX
//
//  Created by 陆广庆 on 2016/12/16.
//  Copyright © 2016年 陆广庆. All rights reserved.
//

import Cocoa
import AVFoundation

class MNScreenRecorder: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {

    var started = false


    var session: AVCaptureSession!
    var input: AVCaptureScreenInput!
    //var output:AVCaptureVideoDataOutput!
    var output: AVCaptureMovieFileOutput!
    
    var lastFrameData: Data!
    
    override init() {
        super.init()
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPreset1280x720//AVCaptureSessionPresetLow //AVCaptureSessionPreset1280x720 AVCaptureSessionPresetLow
        
        input = AVCaptureScreenInput(displayID: CGMainDisplayID())
        input.capturesMouseClicks = true
        input.minFrameDuration = CMTime(seconds: 1.0, preferredTimescale: 60)
        input.scaleFactor = 1.0
        var cropRect = CGRect.zero
        if let screen = NSScreen.screens()?.first {
            cropRect = screen.frame
        }
        input.cropRect = CGRect(x: 0, y: 0, width: 1280, height: 720)
        
        
//        output = AVCaptureVideoDataOutput()
//        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : kCVPixelFormatType_32BGRA]
//        
//        let captureQueue = DispatchQueue(label: "com.lugq1001.eduX")
//        output.setSampleBufferDelegate(self, queue: captureQueue)
        
        output  = AVCaptureMovieFileOutput()
        
        session.addInput(input)
        session.addOutput(output)

    }
    
    func startRecording(url: URL) {
        session.startRunning()
        output.startRecording(toOutputFileURL: url, recordingDelegate: self)
        started = true
    }
    
    func pauseRecording() {
        output.pauseRecording()
        started = false
    }
    
    func resumeRecording() {
        output.resumeRecording()
        started = true
    }
    
    func stopRecording() {
        session.stopRunning()
        lastFrameData = nil
        started = false
    }
    
    // MARK : - AVCaptureFileOutputRecordingDelegate
    public func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
            let baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
            let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
            
            let width = CVPixelBufferGetWidth(imageBuffer)
            let height = CVPixelBufferGetHeight(imageBuffer)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
           
            if let newContext = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue) {
                if let newImage = newContext.makeImage() {
                    
                    CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
                    
                    let bitmapRep = NSBitmapImageRep(cgImage: newImage)
                    let imageCompression = 0.5
                    let jpegOptions: [String : Any] = [NSImageCompressionFactor : imageCompression, NSImageProgressive : false]
                    if let jpegData = bitmapRep.representation(using: NSJPEGFileType, properties: jpegOptions) {
                        if lastFrameData == nil {
                            lastFrameData = jpegData
                        } else {
                            if jpegData.elementsEqual(lastFrameData) {
                                Swift.print("Duplicate frame")
                                return
                            } else {
                                lastFrameData = jpegData
                            }
                        }
                    }
                }
                
            }

        }
    }
    
    
}











