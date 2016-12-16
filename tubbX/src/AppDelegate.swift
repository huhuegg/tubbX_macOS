//
//  AppDelegate.swift
//  tubbX
//
//  Created by 陆广庆 on 2016/12/16.
//  Copyright © 2016年 陆广庆. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var item: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        item = NSStatusBar.system().statusItem(withLength: 20)
        let image = NSImage(named: "ic_statusBar")
        image?.isTemplate = true
        item.image = image
        item.highlightMode = true
        item.action = #selector(recordScreen)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


    func recordScreen() {
        Swift.print("recordScreen")
        //let s = CVPixelBufferGetBytesPerRow(<#T##pixelBuffer: CVPixelBuffer##CVPixelBuffer#>)
    }
}

