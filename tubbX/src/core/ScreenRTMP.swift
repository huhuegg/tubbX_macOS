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
import VideoToolbox

class ScreenRTMP: NSObject {
    
    static let kPublishURL = "rtmp://222.73.196.99/hls"
    
    var connection = RTMPConnection()
    var stream: RTMPStream!
    
    static var playUrl: String {
        //let deviceNumber = AppHelper.deviceSerialNumber()
        //let rtmpUrl = "\(deviceNumber)"
        return ScreenRTMP.kPublishURL + "/live"
    }
    
    override init() {
        super.init()
        stream = RTMPStream(connection: connection)
        
        //rtmpStream.attachCamera(DeviceUtil.device(withLocalizedName: cameraPopUpButton.itemTitles[cameraPopUpButton.indexOfSelectedItem], mediaType: AVMediaTypeVideo))
        
        stream.captureSettings = [
            "fps": 15, // FPS
            "sessionPreset": AVCaptureSessionPreset1280x720, // input video width/height
            "continuousAutofocus": false, // use camera autofocus mode
            "continuousExposure": false, //  use camera exposure mode
        ]
        
        stream.videoSettings = [
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
        
    }
    
    func startPublish(input: AVCaptureScreenInput) {
        stream.attachScreen(input)
        //stream.attachAudio(DeviceUtil.device(withLocalizedName: audioPopUpButton.itemTitles[audioPopUpButton.indexOfSelectedItem], mediaType: AVMediaTypeAudio))
        connection.addEventListener(Event.RTMP_STATUS, selector:#selector(ScreenRTMP.rtmpStatusHandler(_:)), observer: self)
        connection.connect(ScreenRTMP.kPublishURL)
    }
    
    func stopPublish() {
        connection.removeEventListener(Event.RTMP_STATUS, selector:#selector(ScreenRTMP.rtmpStatusHandler(_:)), observer: self)
        connection.close()
    }
    
    func rtmpStatusHandler(_ notification:Notification) {
        let e = Event.from(notification)
        if let data = e.data as? ASObject, let code = data["code"] as? String {
            switch code {
            case RTMPConnection.Code.connectSuccess.rawValue:
                stream.publish("live")
            default:
                break
            }
        }
    }
}

