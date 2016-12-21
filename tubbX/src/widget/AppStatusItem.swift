//
//  AppStatusItem.swift
//  tubbX
//
//  Created by 陆广庆 on 2016/12/21.
//  Copyright © 2016年 陆广庆. All rights reserved.
//

import Cocoa

class AppStatusItem: NSObject {

    var item: NSStatusItem!
    
    func createStatusItem() {
        item = NSStatusBar.system().statusItem(withLength: 20)
        let image = NSImage(named: "ic_statusBar")
        image?.isTemplate = true
        item.image = image
        item.highlightMode = true
        //item.action = #selector(recordScreen)
    }
    
}
