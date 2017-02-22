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

enum VideoQuality {
    case normal
    case height
    case movie
    
    func desc() -> String {
        switch self {
        case .normal: return "标准"
        case .height: return "高质量"
        case .movie: return "高质量视频"
        }
    }
}

class ScreenRTMP: NSObject {
    
    var connection = RTMPConnection()
    var stream: RTMPStream!
    var quality:VideoQuality = .normal
    
    
    init(size:NSSize) {
        super.init()
        stream = RTMPStream(connection: connection)
        stream.captureSettings = [
            "fps": 15, // FPS
            "sessionPreset": AVCaptureSessionPresetHigh, // input video width/height
            "continuousAutofocus": false, // use camera autofocus mode
            "continuousExposure": false, //  use camera exposure mode
        ]
        
        changeVideoSize(size: size)
        
    }
    private func fps() -> Int {
        switch self.quality {
        case .normal:
            return 15
        case .height:
            return 15
        case .movie:
            return 30
        }
    }
    
    private func bitrate() -> Int {
        switch self.quality {
        case .normal:
            return 80 * 1024
        case .height:
            return 8 * 80 * 1024
        case .movie:
            return 8 * 80 * 1024
        }
    }
    
    private func profileLevel() -> CFString {
        switch self.quality {
        case .normal:
            return kVTProfileLevel_H264_Baseline_4_0
        case .height:
            return kVTProfileLevel_H264_Main_AutoLevel
        case .movie:
            return kVTProfileLevel_H264_High_AutoLevel
        }
    }
    
    func changeQuality(quality:VideoQuality) {
        print("修改视频质量为:\(quality.desc)")
        self.quality = quality
        let width = stream.videoSettings["width"] as! CGFloat
        let height = stream.videoSettings["height"] as! CGFloat
        let size = NSSize(width: width, height: height)
        changeVideoSize(size: size)
    }
    
    func changeVideoSize(size:NSSize) {
        
        stream.videoSettings = [
            //            "width": 1280, // video output width
            //            "height": 720, // video output height
            "width": size.width, // video output width
            "height": size.height, // video output height
            "bitrate": bitrate(), // video output bitrate
            // "dataRateLimits": [160 * 1024 / 8, 1], optional kVTCompressionPropertyKey_DataRateLimits property
            "profileLevel": profileLevel(), // H264 Profile require "import VideoToolbox"
            "maxKeyFrameIntervalDuration": 15, // key frame / sec
        ]
    }
    
//    override init() {
//        super.init()
//        stream = RTMPStream(connection: connection)
//        
//        //rtmpStream.attachCamera(DeviceUtil.device(withLocalizedName: cameraPopUpButton.itemTitles[cameraPopUpButton.indexOfSelectedItem], mediaType: AVMediaTypeVideo))
//        
//        stream.captureSettings = [
//            "fps": 15, // FPS
//            "sessionPreset": AVCaptureSessionPreset1280x720, // input video width/height
//            "continuousAutofocus": false, // use camera autofocus mode
//            "continuousExposure": false, //  use camera exposure mode
//        ]
//        
//        stream.videoSettings = [
////            "width": 1280, // video output width
////            "height": 720, // video output height
//            "width": 1162, // video output width
//            "height": 455, // video output height
//            "bitrate": 80 * 1024, // video output bitrate
//            // "dataRateLimits": [160 * 1024 / 8, 1], optional kVTCompressionPropertyKey_DataRateLimits property
//            "profileLevel": kVTProfileLevel_H264_Baseline_4_0, // H264 Profile require "import VideoToolbox"
//            "maxKeyFrameIntervalDuration": 15, // key frame / sec
//        ]
//        
//        // "0" means the same of input
//        //        rtmpStream.recorderSettings = [
//        //            AVMediaTypeAudio: [
//        //                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//        //                AVSampleRateKey: 0,
//        //                AVNumberOfChannelsKey: 0,
//        //                // AVEncoderBitRateKey: 128000,
//        //            ],
//        //            AVMediaTypeVideo: [
//        //                AVVideoCodecKey: AVVideoCodecH264,
//        //                AVVideoHeightKey: 0,
//        //                AVVideoWidthKey: 0,
//        //
//        //                AVVideoCompressionPropertiesKey: [
//        //                    AVVideoMaxKeyFrameIntervalDurationKey: 3,
//        //                    AVVideoAllowFrameReorderingKey: false,
//        //                    AVVideoProfileLevelKey: AVVideoProfileLevelH264BaselineAutoLevel,
//        //                    AVVideoAverageBitRateKey: 0,
//        //                    AVVideoExpectedSourceFrameRateKey: 0,
//        //                    AVVideoAverageNonDroppableFrameRateKey: 0
//        //                ]
//        //
//        //            ],
//        //        ]
//        
//    }
    
    var lastPath = ""
    func startPublish(input: AVCaptureScreenInput, url: String) {
        stream.attachScreen(input)
        //stream.attachAudio(DeviceUtil.device(withLocalizedName: audioPopUpButton.itemTitles[audioPopUpButton.indexOfSelectedItem], mediaType: AVMediaTypeAudio))
        connection.addEventListener(Event.RTMP_STATUS, selector:#selector(ScreenRTMP.rtmpStatusHandler(_:)), observer: self)
        
        var result = ""
        if let u = URL(string: url) {
            lastPath = u.lastPathComponent
            result = url.replacingOccurrences(of: "/\(lastPath)", with: "")
        }
        
        
        connection.connect(result, arguments: nil)
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
                stream.publish(lastPath)
            default:
                break
            }
        }
    }
}

