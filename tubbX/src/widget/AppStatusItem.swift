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
        image?.size = NSSize(width: 20, height: 20)
        
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
        var data = MJWindowManager.instance.allWindowList()
        var dict:Dictionary<String,Array<WindowInfo>> = Dictionary()
        
        
        let menu = NSMenu()
        
        let qualityMenuItem = NSMenuItem(title: "视频质量", action: #selector(self.menuItemClicked(menuItem:)), keyEquivalent: "")
        qualityMenuItem.target = self
        
        let qualitySubMenu = NSMenu()
        let qualityNormalSubMenuTitle = ScreenRecorder.sharedInstance.rtmp.quality == .normal ? "✓ 标准":"标准"
        let qualityNormalSubMenuItem = NSMenuItem(title: qualityNormalSubMenuTitle, action: #selector(self.menuItemClicked(menuItem:)), keyEquivalent: "")
        qualityNormalSubMenuItem.target = self
        qualityNormalSubMenuItem.representedObject = "QualityNormal"
        qualitySubMenu.addItem(qualityNormalSubMenuItem)
        
        let qualityHeightSubMenuTitle = ScreenRecorder.sharedInstance.rtmp.quality == .height ? "✓ 高质量":"高质量"
        let qualityHeightSubMenuItem = NSMenuItem(title: qualityHeightSubMenuTitle, action: #selector(self.menuItemClicked(menuItem:)), keyEquivalent: "")
        qualityHeightSubMenuItem.target = self
        qualityHeightSubMenuItem.representedObject = "QualityHeight"
        qualitySubMenu.addItem(qualityHeightSubMenuItem)

        qualityMenuItem.submenu = qualitySubMenu
        menu.addItem(qualityMenuItem)
        
        
        menu.addItem(NSMenuItem.separator())
        
        let screenMenuTitle = MJWindowManager.instance.isWatchAppWindow() ? "完整屏幕":"✓ 完整屏幕"
        let screenMenuItem = NSMenuItem(title: screenMenuTitle, action: #selector(self.menuItemClicked(menuItem:)), keyEquivalent: "")
        screenMenuItem.target = self
        screenMenuItem.representedObject = data.removeFirst()
        menu.addItem(screenMenuItem)
        

        for windowInfo in data {
            if dict[windowInfo.appName] == nil {
                dict[windowInfo.appName] = Array()
            }
            dict[windowInfo.appName]?.append(windowInfo)
        }
        
        for key in dict.keys {
            if isNeedShow(appName: key) {
                if let appWindowInfos =  dict[key]  {
                    let title = MJWindowManager.instance.isAppWatched(windowInfo: appWindowInfos.first!) ? "✓ \(appWindowInfos.first!.appName!)":"\(appWindowInfos.first!.appName!)"

                    let menuItem = NSMenuItem(title: title, action: #selector(self.menuItemClicked(menuItem:)), keyEquivalent: "")
                    menuItem.target = self
                    
                    let subMenu = NSMenu()
                    for windowInfo in appWindowInfos {
                        let title = MJWindowManager.instance.isWindowWatched(windowInfo: windowInfo) ? "✓ \(windowInfo.windowName!)":"\(windowInfo.windowName!)"
                        let subMenuItem = NSMenuItem(title: title, action: #selector(self.menuItemClicked(menuItem:)), keyEquivalent: "")
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
        //使用item.menu方式添加的menu无法动态修改
        //item.menu = menu
        
        //使用popUpMenu方法动态加载menu
        item.popUpMenu(menu)
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
            print("先激活应用，然后修改截屏位置为指定的应用窗口位置")
            //需要先激活应用，然后修改截屏位置为指定的应用窗口位置
            MJWindowManager.instance.activeApplicationAndWathchWindow(windowInfo: windowInfo)
            
        } else if let quality = menuItem.representedObject as? String {
            if quality == "QualityNormal" {
                ScreenRecorder.sharedInstance.rtmp.changeQuality(quality: .normal)
            } else if quality == "QualityHeight" {
                ScreenRecorder.sharedInstance.rtmp.changeQuality(quality: .height)
            }
        }
    }
    
//    @objc fileprivate func showPopover() {
//        if let statusBarButton = item.button {
//            popOver?.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: NSRectEdge.maxY)
//        }
//
//    }
}



