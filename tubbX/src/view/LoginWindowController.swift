//
//  LoginWindowController.swift
//  tubbX
//
//  Created by 陆广庆 on 2016/12/21.
//  Copyright © 2016年 陆广庆. All rights reserved.
//

import Cocoa

class LoginWindowController: BaseWindowController {

    static var instance: LoginWindowController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        resizeWindow()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        Logger.print("LoginWindowController windowDidLoad")
        LoginWindowController.instance = self
    }
    
    
    fileprivate func resizeWindow() {
        let winW: CGFloat = LoginViewController.kViewWidth
        let winH: CGFloat = LoginViewController.kViewHeight
        if let mainScreen = NSScreen.main() {
            let screenRect = mainScreen.frame
            
            if let win = window {
                var winFrame = win.frame
                winFrame.size = NSSize(width: winW, height: winH)
                winFrame.origin.x = (screenRect.size.width - winW) / 2
                winFrame.origin.y = (screenRect.size.height - winH) / 2
                win.setFrame(winFrame, display: true)
                win.minSize = win.frame.size
                win.maxSize = win.frame.size
            }
        }
    }

}
