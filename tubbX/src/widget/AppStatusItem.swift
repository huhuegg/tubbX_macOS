//
//  AppStatusItem.swift
//  tubbX
//
//  Created by 陆广庆 on 2016/12/21.
//  Copyright © 2016年 陆广庆. All rights reserved.
//

import Cocoa

fileprivate let appStatusItem:AppStatusItem = AppStatusItem()
class AppStatusItem: NSObject {

    var item: NSStatusItem!
//    var popOver:NSPopover?
    
    static var instance: AppStatusItem {
        return appStatusItem
    }
    
    override init() {
        super.init()
    }
    
    func createStatusItem() {
        item = NSStatusBar.system().statusItem(withLength: 20)
        let image = NSImage(named: "ic_statusBar")
        item.image = image
//        image?.isTemplate = true
//        item.highlightMode = true
        
        self.item.target = self
        if let button = item.button {
            button.action = #selector(self.statusBarButtonClicked(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        
        //createPopOver()
    }
    
    func showMenu() {
        let data = MJWindowManager.instance.allWindowList()
        var dict:Dictionary<String,Array<WindowInfo>> = Dictionary()
        for windowInfo in data {
            if dict[windowInfo.appName] == nil {
                dict[windowInfo.appName] = Array()
            }
            dict[windowInfo.appName]?.append(windowInfo)
        }
        
        let menu = NSMenu()
        let screenMenuItem = NSMenuItem(title: "屏幕", action: #selector(self.menuItemClicked(menuItem:)), keyEquivalent: "")
        screenMenuItem.target = self
        screenMenuItem.representedObject = data.first!
        menu.addItem(screenMenuItem)
        
        for key in dict.keys {
            if isNeedShow(appName: key) {
                if let appWindowInfos =  dict[key]  {
                    let title = appWindowInfos.first!.appName

                    let menuItem = NSMenuItem(title: title!, action: #selector(self.menuItemClicked(menuItem:)), keyEquivalent: "")
                    menuItem.target = self
                    
                    let subMenu = NSMenu()
                    for windowInfo in appWindowInfos {
                        let title = windowInfo.windowName
                        let subMenuItem = NSMenuItem(title: title!, action: #selector(self.menuItemClicked(menuItem:)), keyEquivalent: "")
                        subMenuItem.target = self
                        
                        subMenu.addItem(subMenuItem)
                        subMenuItem.representedObject = windowInfo
                    }
                    menuItem.submenu = subMenu
                    menu.addItem(menuItem)
                }
            }
        }
        

        NSMenu.popUpContextMenu(menu, with: NSApp.currentEvent!, for: self.item.button!)
        item.menu = menu
    }
    
//    func createPopOver() {
//        if popOver == nil {
//            popOver = NSPopover()
//            popOver!.behavior = .applicationDefined
//            popOver!.appearance = NSAppearance()
//            popOver!.contentViewController = MyPopoverViewController(nibName: "MyPopoverViewController", bundle: nil)
//            
//            self.item.target = self
//            self.item.button?.action = #selector(showPopover)
//            
//            NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.leftMouseDown) { (event) in
//                if self.popOver!.isShown {
//                    self.popOver!.close()
//                }
//            }
//        }
//    }
    
    func isNeedShow(appName:String) -> Bool {
        let whiteList = ["Xcode","Safari","Google Chrome","Keynote"]
        for i in whiteList {
            if appName == i {
                return true
            }
        }
        return false
    }
}

extension AppStatusItem {
    @objc fileprivate func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == NSEventType.rightMouseUp {
            print("Right click")
        } else {
            print("Left click")
            showMenu()
        }
    }

    @objc fileprivate func menuItemClicked(menuItem: NSMenuItem) {
        print("menuItemClicked")
        if let windowInfo = menuItem.representedObject as? WindowInfo {
            MJWindowManager.instance.watch(windowInfo: windowInfo)
            MJWindowManager.instance.activeApplication(appPid: windowInfo.appPid.intValue)
        }
    }
    
//    @objc fileprivate func showPopover() {
//        if let statusBarButton = item.button {
//            popOver?.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: NSRectEdge.maxY)
//        }
//
//    }
}



