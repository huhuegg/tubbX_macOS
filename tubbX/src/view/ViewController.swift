//
//  ViewController.swift
//  tubbX
//
//  Created by 陆广庆 on 2016/12/16.
//  Copyright © 2016年 陆广庆. All rights reserved.
//

import Cocoa
import lf


class ViewController: NSViewController {

    var lfView: GLLFView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lfView = GLLFView(frame: NSRect(x: 0, y: 0, width: 480, height: 270))
        view.addSubview(lfView)
        
        
        let rtmp = ScreenRTMP(view: lfView)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

