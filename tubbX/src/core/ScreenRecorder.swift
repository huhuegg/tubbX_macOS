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
    var rtmp:ScreenRTMP!
//    var local:ScreenLocal!
    
    var input: AVCaptureScreenInput!
    private var recordDisplayID:CGDirectDisplayID = CGMainDisplayID()
    var i:Int = 1
    
    override init() {
        super.init()
        
        if let input = AVCaptureScreenInput(displayID: CGMainDisplayID()) {
            input.capturesMouseClicks = true
            input.minFrameDuration = CMTime(seconds: 1.0, preferredTimescale: 30)
            input.scaleFactor = 1
            
            self.input = input

            rtmp = ScreenRTMP(size: self.input.cropRect.size)
//            local = ScreenLocal(size: self.input.cropRect.size)
        }
    }
    
    func lastDisplayID() -> CGDirectDisplayID {
        return recordDisplayID
    }
    
    func changeScreen(displayID:CGDirectDisplayID) {
        recordDisplayID = displayID
        
        changeWantedRect()
    }
    
    func changeWantedRect() {
        print("ScreenRecorder.changeWantedRect")
        self.input.cropRect = MJWindowManager.instance.watchedRect()
        rtmp.changeVideoSize(size: self.input.cropRect.size)
    }
    
    func isRecording() -> Bool {
        return recording
    }
    
    func startRecord(publishUrl: String) {
        recording = true
        rtmp.startPublish(input: input, url: publishUrl)
//        local.startPublish(input: input)
    }
    
    func stopRecord() {

        rtmp.stopPublish()
        recording = false
    }

}

extension ScreenRecorder {
    func debugPrintDisplayInfos() {
        let maxDisplays: UInt32 = 16
        var onlineDisplays = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplays))
        var displayCount: UInt32 = 0
        
        let dErr = CGGetOnlineDisplayList(maxDisplays, &onlineDisplays, &displayCount)
        
        print("displayCount: \(displayCount)")
        
        for currentDisplay in onlineDisplays[0..<Int(displayCount)] {
            print("currentDisplay is \(currentDisplay)")
            print("CGDisplayPixelsHigh(currentDisplay) is \(CGDisplayPixelsHigh(currentDisplay))")
            print("CGDisplayPixelsWide(currentDisplay) is \(CGDisplayPixelsWide(currentDisplay))")
        }
    }
    
    func screenSize() -> NSSize {
        let screens = NSScreen.screens()
        for screen in screens! {
            let screenDescription = screen.deviceDescription
            if let screenSize = screenDescription["NSDeviceSize"] as? NSSize {
                return screenSize
            }
        }
        return NSZeroSize
    }
    
    func converRect(size:NSSize, point:NSPoint) -> CGRect {
        let sSize = screenSize()
        if sSize == NSZeroSize {
            print("获取屏幕尺寸失败")
            return CGRect.zero
        }
        
        return CGRect(x: point.x, y: sSize.height - size.height - point.y, width: size.width, height: size.height)
    }
}











