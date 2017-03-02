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

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        AppEvent.instance.addEvent()
//        
        AppStatusItem.instance.createStatusItem()
        
        
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
//    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
//        if flag {
//            return false
//        } else {
//            LoginWindowController.instance.showWindow(self)
//        }
//        return true
//    }

}
