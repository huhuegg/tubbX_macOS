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

