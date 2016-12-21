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
    
    func isRecording() -> Bool {
        return recording
    }
    
    func startRecord() {
        recording = true
    }
    
    func stopRecord() {
        recording = false
    }
}











