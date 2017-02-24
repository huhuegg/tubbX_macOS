//
//  ScreenLocal.swift
//  LiveScreen
//
//  Created by huhuegg on 2017/2/24.
//  Copyright © 2017年 陆广庆. All rights reserved.
//

import Cocoa
import AVFoundation
import VideoToolbox

class ScreenLocal: NSObject {
    var captureSession:AVCaptureSession!
    var captureMovieFileOutPut:AVCaptureMovieFileOutput?
    
    init(size:NSSize) {
        super.init()
        captureSession = AVCaptureSession()
    }
    
    func startPublish(input: AVCaptureScreenInput) {
        //创建AVCaptureSession对象
        
        if captureSession.canSetSessionPreset(AVCaptureSessionPreset1280x720){
            captureSession.sessionPreset = AVCaptureSessionPreset1280x720
        }
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
            if let audioCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio) {
                do {
                    let audioInput = try AVCaptureDeviceInput(device: audioCaptureDevice)
                    if captureSession.canAddInput(audioInput) {
                        captureSession.addInput(audioInput)
                    }
                } catch {
                    print("获取音频输出设备失败")
                }
            }
        }
        
        //初始化输出对象，用于获得输出数据
        captureMovieFileOutPut = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(captureMovieFileOutPut){
            captureSession.addOutput(captureMovieFileOutPut)
        }
        
        beginRecorderMovie()
    }

    func stopPublish() {
        if let _ = captureMovieFileOutPut {
            captureMovieFileOutPut!.stopRecording()
        }
    }
    
    func beginRecorderMovie(){
        if let _ = captureMovieFileOutPut {
            //根据连接获得设备输出的数据
            if !captureMovieFileOutPut!.isRecording {

                let outputFielPath = NSTemporaryDirectory() + "myMovie.mov"
                let url = URL(fileURLWithPath:outputFielPath)
                print("outputURL:\(url.absoluteString)")
                captureMovieFileOutPut!.startRecording(toOutputFileURL: url, recordingDelegate: self)
            } else {
                captureMovieFileOutPut!.stopRecording()
            }
        }

        
    }
}

extension ScreenLocal: AVCaptureFileOutputRecordingDelegate {
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("\(#function)")
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didPauseRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("\(#function)")
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didResumeRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("\(#function)")
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, willFinishRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print("\(#function)")
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print("\(#function)")
    }
    
}

//extension ScreenLocal: AVCaptureFileOutputRecordingDelegate {
////    
////    //视频输出代理
////    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
////        print("录制完毕")
//////        assetsLibrary.writeVideoAtPathToSavedPhotosAlbum(outputFileURL) { (assetUrl, error) -> Void in
//////            if error != nil {
//////                
//////                print("保存相册过程中失败")
//////                
//////            }
//////            do {
//////                try NSFileManager.defaultManager().removeItemAtURL(outputFileURL)
//////                
//////            }catch{}
//////            if lastBackgroundTaskIdentifier != UIBackgroundTaskInvalid {
//////                UIApplication.sharedApplication().endBackgroundTask(lastBackgroundTaskIdentifier)
//////            }
//////        }
////    }
////    
////    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
////        print("开始录制")
////    }
//
//}
