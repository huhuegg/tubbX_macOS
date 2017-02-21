//
//  LoginViewController.swift
//  tubbX
//
//  Created by 陆广庆 on 2016/12/21.
//  Copyright © 2016年 陆广庆. All rights reserved.
//

import Cocoa
import SnapKit

class LoginViewController: BaseViewController {
    
    static var instance: LoginViewController!
    
    
    
    static let kViewWidth: CGFloat = 320
    static let kViewHeight: CGFloat = 344
    static let kViewPadding: CGFloat = 24
    
    var qrImageView: NSImageView!
    var shareScreenButton: NSButton!
    var tipLabel: NSTextField!
    
    let wsClient = WSClient.sharedInstance
    
    var progressIndicator: NSProgressIndicator!
    var publishUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.networkResp(n:)), name: Notification.Name(rawValue: "NetworkResp"), object: nil)
        
        
        wsClient.start()
        
        LoginViewController.instance = self
        Logger.print("LoginViewController viewDidLoad")
        initView()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        progressIndicator.startAnimation(self)
        let command = RegisterCommand(kIdentifier).makeCommand()
        wsClient.sendMessage(message: command)
        
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        wsClient.stop()
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "NetworkResp"), object: nil)
    }
    
    func initView() {
        
        progressIndicator = NSProgressIndicator()
        progressIndicator.isDisplayedWhenStopped = false
        progressIndicator.style = .spinningStyle
        view.addSubview(progressIndicator)
        progressIndicator.snp.updateConstraints { (maker) in
            maker.center.equalToSuperview()
            maker.width.equalTo(50)
            maker.height.equalTo(50)
        }
        
        tipLabel = NSTextField(frame: NSRect.zero)
        tipLabel.textColor = NSColor.red
        tipLabel.alignment = .center
        tipLabel.isEditable = false
        tipLabel.drawsBackground = false
        tipLabel.isBezeled = false
        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(20)
            maker.right.equalToSuperview().offset(-20)
            maker.top.equalTo(progressIndicator.snp.bottom).offset(12)
            maker.height.equalTo(40)
        }
        tipLabel.stringValue = ""
        
        // 二维码图片
        qrImageView = NSImageView()
        view.addSubview(qrImageView)
        qrImageView.snp.makeConstraints { (maker) in
            maker.leading.top.equalToSuperview().offset(LoginViewController.kViewPadding)
            maker.trailing.equalToSuperview().offset(-LoginViewController.kViewPadding)
            maker.height.equalTo(qrImageView.snp.width)
        }
        
        qrImageView.isHidden = true
        
        
        // 屏幕共享按钮
        let btn = NSButton()
        let cell = NSButtonCell()
        cell.backgroundColor = NSColor.white
        //        cell.isBordered = false
        
        cell.attributedTitle = buttonTitle("开始屏幕分享")
        
        btn.cell = cell
        shareScreenButton = btn
        
        view.addSubview(shareScreenButton)
        
        shareScreenButton.snp.makeConstraints { (maker) in
            maker.centerY.equalToSuperview()
            maker.leading.equalToSuperview().offset(LoginViewController.kViewPadding)
            maker.trailing.equalToSuperview().offset(-LoginViewController.kViewPadding)
            maker.height.equalTo(60)
        }
        shareScreenButton.action = #selector(LoginViewController.startShareScreen)
        shareScreenButton.target = self
        shareScreenButton.isHidden = true
    }
    
    
    /// 按钮文字样式
    ///
    /// - Parameter title: 文字
    /// - Returns:
    func buttonTitle(_ title: String) -> NSAttributedString {
        let coloredTitle = NSMutableAttributedString(string: title)
        let titleRange = NSRange(location: 0, length: title.characters.count)
        
        coloredTitle.addAttributes([NSForegroundColorAttributeName : NSColor.brown,
                                    NSFontAttributeName : NSFont.boldSystemFont(ofSize: 20)], range: titleRange)
        
        let centeredAttribute = NSMutableParagraphStyle()
        centeredAttribute.alignment = .center
        coloredTitle.addAttributes([NSParagraphStyleAttributeName : centeredAttribute], range: titleRange)
        
        return coloredTitle
    }
    
    func startShareScreen() {
        let record = ScreenRecorder.sharedInstance
        if record.isRecording() {
            let record = ScreenRecorder.sharedInstance
            record.stopRecord()
//            Logger.print("结束屏幕分享")
//            shareScreenButton.isHidden = true
//            progressIndicator.startAnimation(self)
//            let command = StopRecordCommand(kIdentifier).makeCommand()
//            wsClient.sendMessage(message: command)
        } else {
            Logger.print("开始屏幕分享")
            shareScreenButton.isHidden = true
            progressIndicator.startAnimation(self)
            let command = StartRecordCommand(kIdentifier).makeCommand()
            wsClient.sendMessage(message: command)
        }
    }
    
    func networkResp(n: Notification) {
        if let userInfo = n.userInfo {
            let command = userInfo["command"] as! String
            let ret_code = userInfo["ret_code"] as! Int
            let ret_msg = userInfo["ret_msg"] as! String
            switch command {
            case "Register":
                // 设备注册
                progressIndicator.stopAnimation(self)
                if ret_code == 0 {
                    if let qr = userInfo["qr"] {
                        let q = qr as! String
                        showQRImage(q)
                    } else {
                        // 已绑定
                        publishUrl = userInfo["publishUrl"] as! String
                        qrImageView.isHidden = true
                        shareScreenButton.isHidden = false
                    }
                    
                } else {
                    tipLabel.stringValue = ret_msg
                }
            case "BindClient":
                // 绑定设备成功
                Logger.print("绑定设备成功")
                publishUrl = userInfo["publishUrl"] as! String
                qrImageView.isHidden = true
                shareScreenButton.isHidden = false
            case "StartRecord":
                // 开始屏幕分享
                Logger.print("开始屏幕分享")
                progressIndicator.stopAnimation(self)
                shareScreenButton.isHidden = false
                (shareScreenButton.cell as! NSButtonCell).attributedTitle = buttonTitle("结束屏幕分享")
                let record = ScreenRecorder.sharedInstance
                record.startRecord(publishUrl: publishUrl)
            case "StopRecord":
                // 结束屏幕分享
                Logger.print("结束屏幕分享")
                shareScreenButton.isHidden = false
                progressIndicator.stopAnimation(self)
                let record = ScreenRecorder.sharedInstance
                record.stopRecord()
                (shareScreenButton.cell as! NSButtonCell).attributedTitle = buttonTitle("开始屏幕分享")
            case "UnboundClient":
                Logger.print("解绑")
                let record = ScreenRecorder.sharedInstance
                if record.isRecording() {
                    record.stopRecord()
                    shareScreenButton.isHidden = false
                    progressIndicator.stopAnimation(self)
                    (shareScreenButton.cell as! NSButtonCell).attributedTitle = buttonTitle("开始屏幕分享")
                }
                shareScreenButton.isHidden = true
                // 解绑设备成功
                let qr = userInfo["qr"] as! String
                // 显示二维码
                showQRImage(qr)
                
                LoginWindowController.instance.showWindow(self)
            default:
                break
            }
        }
    }
    
    
    /// 展示二维码图片
    ///
    /// - Parameter qr: 二维码内容
    fileprivate func showQRImage(_ qr: String) {
        let size = view.frame.size.width - LoginViewController.kViewPadding * 2
        Logger.print("qrCode:\(qr)")
        if let image = QRCode.generateQRImage(from: qr, size: size) {
            qrImageView.image = image
        }
        qrImageView.isHidden = false
    }
    
}











