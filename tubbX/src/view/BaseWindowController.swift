//
//  BaseWindowController.swift
//  tubbX
//
//  Created by 陆广庆 on 2016/12/21.
//  Copyright © 2016年 陆广庆. All rights reserved.
//

import Cocoa

class BaseWindowController: NSWindowController {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.window?.title = ""
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        
    }
    
    

}
