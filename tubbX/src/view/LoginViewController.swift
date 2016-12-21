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
    static let kViewHeight: CGFloat = 440
    static let kViewPadding: CGFloat = 24
    
    var qrImageView: NSImageView!
    var shareScreenButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoginViewController.instance = self
        Logger.print("LoginViewController viewDidLoad")
        initView()
    }
    
    func initView() {
        // 二维码图片
        qrImageView = NSImageView()
        view.addSubview(qrImageView)
        qrImageView.snp.makeConstraints { (maker) in
            maker.leading.top.equalToSuperview().offset(LoginViewController.kViewPadding)
            maker.trailing.equalToSuperview().offset(-LoginViewController.kViewPadding)
            maker.height.equalTo(qrImageView.snp.width)
        }
        
        let size = view.frame.size.width - LoginViewController.kViewPadding * 2
        
        let qrCode = ScreenRTMP.playUrl
        Logger.print("qrCode:\(qrCode)")
        if let image = QRCode.generateQRImage(from: qrCode, size: size) {
            qrImageView.image = image
        }
        
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
            maker.top.equalTo(qrImageView.snp.bottom).offset(LoginViewController.kViewPadding)
            maker.leading.equalToSuperview().offset(LoginViewController.kViewPadding)
            maker.trailing.equalToSuperview().offset(-LoginViewController.kViewPadding)
            maker.bottom.equalToSuperview().offset(-LoginViewController.kViewPadding)
        }
        shareScreenButton.action = #selector(LoginViewController.startShareScreen)
        shareScreenButton.target = self
        
    }
    
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
            record.stopRecord()
            Logger.print("结束屏幕分享")
            (shareScreenButton.cell as! NSButtonCell).attributedTitle = buttonTitle("开始屏幕分享")
        } else {
            Logger.print("开始屏幕分享")
            (shareScreenButton.cell as! NSButtonCell).attributedTitle = buttonTitle("结束屏幕分享")
            LoginWindowController.instance.close()
            record.startRecord()
        }
    }
    
    
}
