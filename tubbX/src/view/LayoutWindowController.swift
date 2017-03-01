//
//  LayoutWindowController.swift
//  LiveScreen
//
//  Created by huhuegg on 2017/2/28.
//  Copyright © 2017年 陆广庆. All rights reserved.
//

import Cocoa

class LayoutWindowController: NSWindowController {

    fileprivate var panel: NSPanel! {
        get {
            return (self.window as! NSPanel)
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        if let w = self.window, let s = NSScreen.main() {
            let rect = NSRect(origin: CGPoint.zero, size: CGSize(width: s.frame.size.width, height: w.frame.size.height))
            w.setFrame(rect, display: false)
        }
        
        initView(isVisible: false)
    }
    
    func initView(isVisible:Bool) {
        //设置为keyWindow 置于前端
        panel.makeKeyAndOrderFront(self)
        //设置透明度
        panel.animator().alphaValue = 0.3
        //设置不透明为false
        panel.isOpaque = false
        //忽略鼠标事件
        panel.ignoresMouseEvents = true
        //设置为不可移动(如已设置ignoresMouseEvents可不指定)
        //panel.isMovable = false
        //窗口设置为可见
        panel.setIsVisible(isVisible)
    }

}
