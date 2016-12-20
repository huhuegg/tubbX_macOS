//
//  ScreenRTMP.swift
//  tubbX
//
//  Created by 陆广庆 on 2016/12/19.
//  Copyright © 2016年 陆广庆. All rights reserved.
//

import Cocoa
import lf
import AVFoundation


class ScreenRTMP: NSObject {

    let url = "rtmp://tubbx.oss-cn-hangzhou.aliyuncs.com/live/mac"
    
    var rtmpConnection:RTMPConnection = RTMPConnection()
    var rtmpStream:RTMPStream!
    
    
    init(view: GLLFView) {
        super.init()
        rtmpStream = RTMPStream(connection: rtmpConnection)
        //rtmpStream.attachAudio(DeviceUtil.device(withLocalizedName: audioPopUpButton.itemTitles[audioPopUpButton.indexOfSelectedItem], mediaType: AVMediaTypeAudio))
        //rtmpStream.attachCamera(DeviceUtil.device(withLocalizedName: cameraPopUpButton.itemTitles[cameraPopUpButton.indexOfSelectedItem], mediaType: AVMediaTypeVideo))
        
        
        if let input = AVCaptureScreenInput(displayID: CGMainDisplayID()) {
            input.capturesMouseClicks = true
            input.minFrameDuration = CMTime(seconds: 1.0, preferredTimescale: 60)
            input.scaleFactor = 0.5
            var cropRect = CGRect.zero
            if let screen = NSScreen.screens()?.first {
                cropRect = screen.frame
            }
            input.cropRect = cropRect
            rtmpStream.attachScreen(input)
        }
        
        rtmpStream.addObserver(self, forKeyPath: "currentFPS", options: .new, context: nil)
        view.attachStream(rtmpStream)
        
        
        
        
        /////
        
        rtmpStream = RTMPStream(connection: rtmpConnection)
        
        //rtmpStream.attachCamera(DeviceUtil.device(withLocalizedName: cameraPopUpButton.itemTitles[cameraPopUpButton.indexOfSelectedItem], mediaType: AVMediaTypeVideo))
        
        rtmpStream.captureSettings = [
            "fps": 15, // FPS
            "sessionPreset": AVCaptureSessionPreset1280x720, // input video width/height
            "continuousAutofocus": false, // use camera autofocus mode
            "continuousExposure": false, //  use camera exposure mode
        ]
        
        rtmpStream.videoSettings = [
            "width": 1280, // video output width
            "height": 720, // video output height
            "bitrate": 80 * 1024, // video output bitrate
            // "dataRateLimits": [160 * 1024 / 8, 1], optional kVTCompressionPropertyKey_DataRateLimits property
            "profileLevel": kVTProfileLevel_H264_Baseline_4_0, // H264 Profile require "import VideoToolbox"
            "maxKeyFrameIntervalDuration": 15, // key frame / sec
        ]
        
        // "0" means the same of input
        //        rtmpStream.recorderSettings = [
        //            AVMediaTypeAudio: [
        //                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        //                AVSampleRateKey: 0,
        //                AVNumberOfChannelsKey: 0,
        //                // AVEncoderBitRateKey: 128000,
        //            ],
        //            AVMediaTypeVideo: [
        //                AVVideoCodecKey: AVVideoCodecH264,
        //                AVVideoHeightKey: 0,
        //                AVVideoWidthKey: 0,
        //
        //                AVVideoCompressionPropertiesKey: [
        //                    AVVideoMaxKeyFrameIntervalDurationKey: 3,
        //                    AVVideoAllowFrameReorderingKey: false,
        //                    AVVideoProfileLevelKey: AVVideoProfileLevelH264BaselineAutoLevel,
        //                    AVVideoAverageBitRateKey: 0,
        //                    AVVideoExpectedSourceFrameRateKey: 0,
        //                    AVVideoAverageNonDroppableFrameRateKey: 0
        //                ]
        //
        //            ],
        //        ]
        
        if let input = AVCaptureScreenInput(displayID: CGMainDisplayID()) {
            input.capturesMouseClicks = true
            input.minFrameDuration = CMTime(seconds: 1.0, preferredTimescale: 20)
            input.scaleFactor = 1
            var cropRect = CGRect.zero
            if let screen = NSScreen.screens()?.first {
                cropRect = screen.frame
                //cropRect = NSRect(x: 150, y: 300, width: 1280, height: 720)
            }
            input.cropRect = cropRect
            rtmpStream.attachScreen(input)
        }
        rtmpStream.attachAudio(DeviceUtil.device(withLocalizedName: audioPopUpButton.itemTitles[audioPopUpButton.indexOfSelectedItem], mediaType: AVMediaTypeAudio))
        
        rtmpStream.addObserver(self, forKeyPath: "currentFPS", options: .new, context: nil)
        publishButton.target = self
        
        lfView.attachStream(rtmpStream)
        
    }
    
    func publish() {
        rtmpConnection.addEventListener(Event.RTMP_STATUS, selector:#selector(ScreenRTMP.rtmpStatusHandler(_:)), observer: self)
        rtmpConnection.connect(url)
    }
    
    func rtmpStatusHandler(_ notification: Notification) {
        let e:Event = Event.from(notification)
        if let data:ASObject = e.data as? ASObject , let code:String = data["code"] as? String {
            switch code {
            case RTMPConnection.Code.connectSuccess.rawValue:
                rtmpStream!.publish("live")
//                if (enabledSharedObject) {
//                    sharedObject = RTMPSharedObject.getRemote(withName: "test", remotePath: urlField.stringValue, persistence: false)
//                    sharedObject.connect(rtmpConnection)
//                sharedObject.setProperty("Hello", "World!!")
//                }
            default:
                break
            }
        }
    }
}

