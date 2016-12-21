//
//  ScreenRecorder.swift
//  eduX
//
//  Created by 陆广庆 on 2016/12/16.
//  Copyright © 2016年 陆广庆. All rights reserved.
//

import Cocoa
import AVFoundation

class ScreenRecorder: NSObject {

    static let sharedInstance = ScreenRecorder()


    var recording = false
    let rtmp = ScreenRTMP()
    var input: AVCaptureScreenInput!
    
    override init() {
        super.init()
        if let input = AVCaptureScreenInput(displayID: CGMainDisplayID()) {
            input.capturesMouseClicks = true
            input.minFrameDuration = CMTime(seconds: 1.0, preferredTimescale: 20)
            input.scaleFactor = 1
            var cropRect = CGRect.zero
            if let screen = NSScreen.screens()?.first {
                cropRect = screen.frame
            }
            input.cropRect = cropRect
            self.input = input
        }
    }
    
    
    func isRecording() -> Bool {
        return recording
    }
    
    func startRecord() {
        recording = true
        rtmp.startPublish(input: input)
    }
    
    func stopRecord() {
        rtmp.stopPublish()
        recording = false
    }
}











