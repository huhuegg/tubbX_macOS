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
    var popOver:NSPopover?
    var popOverViewController:MyPopoverViewController?
    var whiteList = ["Xcode","Safari","Google Chrome","Keynote","QuickTime Player"]
    
    static var instance: AppStatusItem {
        return appStatusItem
    }
    
    override init() {
        super.init()
        popOverViewController = MyPopoverViewController(nibName: "MyPopoverViewController", bundle: nil)
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
        
        
        createQRCodePopOver()
    }
    
    func showMenu() {
        print("showMenu")
        var data = MJWindowManager.instance.allWindowList()
        var dict:Dictionary<String,Array<WindowInfo>> = Dictionary()
        for windowInfo in data {
//            if windowInfo.appName == "Screen" {
//                continue
//            }
            if windowInfo.windowBounds.size.height < 100 || windowInfo.windowBounds.size.width < 100 {
                continue
            }
            if dict[windowInfo.appName] == nil {
                dict[windowInfo.appName] = Array()
            }
            dict[windowInfo.appName]?.append(windowInfo)
        }

        
        let menu = NSMenu()
        //录制
        let recordMenuTitle = ScreenRecorder.sharedInstance.isRecording() ? "结束录制":"开始录制"
        let recordMenuItem = NSMenuItem(title: recordMenuTitle, action: #selector(self.menuItemClicked(menuItem:)), keyEquivalent: "")
        recordMenuItem.target = self
        recordMenuItem.representedObject = ScreenRecorder.sharedInstance.isRecording() ? "StopRecord":"StartRecord"
        menu.addItem(recordMenuItem)
        menu.addItem(NSMenuItem.separator())
        
        //显示器
        if let screens = NSScreen.screens() {
            let screenMenuItem = NSMenuItem(title: "显示器", action: #selector(self.menuItemClicked(menuItem:)), keyEquivalent: "")
            screenMenuItem.target = self
            
            let screenSubMenu = NSMenu()
            for (index,screen) in screens.enumerated() {
                var screenSubMenuTitle = ""
                let displayID = screen.deviceDescription["NSScreenNumber"] as! CGDirectDisplayID
                if displayID == ScreenRecorder.sharedInstance.lastDisplayID() {
                    screenSubMenuTitle = "✓ "
                }
                
                screenSubMenuTitle += "显示器\(index + 1)"
                if displayID == CGMainDisplayID() {
                    screenSubMenuTitle += " (主屏幕)"
                }
                let screenSubMenuItem = NSMenuItem(title: screenSubMenuTitle, action: #selector(self.menuItemClicked(menuItem:)), keyEquivalent: "")
                screenSubMenuItem.target = self
                screenSubMenuItem.representedObject = displayID
                screenSubMenu.addItem(screenSubMenuItem)
            }
            screenMenuItem.submenu = screenSubMenu
            menu.addItem(screenMenuItem)
            menu.addItem(NSMenuItem.separator())
        }
        
        //可录制应用列表
        let appListMenuItem = NSMenuItem(title: "可录制应用列表", action: #selector(self.menuItemClicked(menuItem:)), keyEquivalent: "")
        appListMenuItem.target = self
        let appListSubMenu = NSMenu()
        for key in dict.keys {
            let appTitle = isNeedShow(appName: key) ? "✓ ":""
            let appMenuItem = NSMenuItem(title: appTitle + key, action: #selector(self.menuItemClicked(menuItem:)), keyEquivalent: "")
            appMenuItem.target = self
            appMenuItem.representedObject = dict[key]
            appListSubMenu.addItem(appMenuItem)
        }
        appListMenuItem.submenu = appListSubMenu
        menu.addItem(appListMenuItem)
        menu.addItem(NSMenuItem.separator())

        //声音
        let voiceMenuItem = NSMenuItem(title: "声音", action: #selector(self.menuItemClicked(menuItem:)), keyEquivalent: "")
        voiceMenuItem.target = self
        
        let voiceSubMenu = NSMenu()
        let voiceEnableSubMenuTitle = ScreenRecorder.sharedInstance.rtmp.audioMuted == false ? "✓ 开启":"开启"
        let voiceEnableSubMenuItem = NSMenuItem(title: voiceEnableSubMenuTitle, action: #selector(self.menuItemClicked(menuItem:)), keyEquivalent: "")
        voiceEnableSubMenuItem.target = self
        voiceEnableSubMenuItem.representedObject = "voiceMenuItem"
        voiceSubMenu.addItem(voiceEnableSubMenuItem)

        //FIXME:- AACEncoder在静音时会崩溃，待处理
//        let voiceMutedSubMenuTitle = ScreenRecorder.sharedInstance.rtmp.audioMuted == true ? "✓ 关闭":"关闭"
//        let voiceMutedSubMenuItem = NSMenuItem(title: voiceMutedSubMenuTitle, action: #selector(self.menuItemClicked(menuItem:)), keyEquivalent: "")
//        voiceMutedSubMenuItem.target = self
//        voiceMutedSubMenuItem.representedObject = "VoiceMuted"
//        voiceSubMenu.addItem(voiceMutedSubMenuItem)
        
        voiceMenuItem.submenu = voiceSubMenu
        menu.addItem(voiceMenuItem)
        menu.addItem(NSMenuItem.separator())
        
        
        
        //视频质量
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

        let qualityHeightMovieSubMenuTitle = ScreenRecorder.sharedInstance.rtmp.quality == .movie ? "✓ 高质量视频":"高质量视频"
        let qualityHeightMovieSubMenuItem = NSMenuItem(title: qualityHeightMovieSubMenuTitle, action: #selector(self.menuItemClicked(menuItem:)), keyEquivalent: "")
        qualityHeightMovieSubMenuItem.target = self
        qualityHeightMovieSubMenuItem.representedObject = "QualityHeightMovie"
        qualitySubMenu.addItem(qualityHeightMovieSubMenuItem)
        
        qualityMenuItem.submenu = qualitySubMenu
        menu.addItem(qualityMenuItem)
        
        
        menu.addItem(NSMenuItem.separator())
        
        //录制区域
        let recordRectMenuItem = NSMenuItem(title: "录制区域", action: #selector(self.menuItemClicked(menuItem:)), keyEquivalent: "")
        recordRectMenuItem.target = self
        let recordRectSubMenu = NSMenu()

        let screenMenuTitle = MJWindowManager.instance.isWatchAppWindow() ? "完整屏幕":"✓ 完整屏幕"
        let screenMenuItem = NSMenuItem(title: screenMenuTitle, action: #selector(self.menuItemClicked(menuItem:)), keyEquivalent: "")
        screenMenuItem.target = self
        screenMenuItem.representedObject = data.removeFirst()
        recordRectSubMenu.addItem(screenMenuItem)
        
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
                    recordRectSubMenu.addItem(menuItem)
                }
            }
        }
        recordRectMenuItem.submenu = recordRectSubMenu
        menu.addItem(recordRectMenuItem)
        
        
        //使用popUpMenu方法动态加载menu
        print("popUpMenu")
        item.popUpMenu(menu)
    }
    
    func createQRCodePopOver() {
        if popOver == nil {
            popOver = NSPopover()
            popOver!.behavior = .transient
            popOver!.appearance = NSAppearance()
            popOver!.contentViewController = popOverViewController

        }
    }
    
    func isNeedShow(appName:String) -> Bool {
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
        if let appWindowInfos = menuItem.representedObject as? Array<WindowInfo> {
            guard let windowInfo = appWindowInfos.first else {
                return
            }
            guard let appName = windowInfo.appName else {
                return
            }
            
            if let index = whiteList.index(of: appName) {
                whiteList.remove(at: index)
            } else {
                whiteList.append(appName)
            }
        } else if let windowInfo = menuItem.representedObject as? WindowInfo {
            print("先激活应用，然后修改截屏位置为指定的应用窗口位置")
            //需要先激活应用，然后修改截屏位置为指定的应用窗口位置
            MJWindowManager.instance.activeApplicationAndWathchWindow(windowInfo: windowInfo)
            
        } else if let str = menuItem.representedObject as? String {
            if str == "StartRecord" {
                showPopover()
            } else if str == "StopRecord" {
                popOverViewController?.stop()
            } else if str == "VoiceEnable" {
                ScreenRecorder.sharedInstance.rtmp.changeAudio(mute: false)
            } else if str == "VoiceMuted" {
                ScreenRecorder.sharedInstance.rtmp.changeAudio(mute: true)
            } else if str == "QualityNormal" {
                ScreenRecorder.sharedInstance.rtmp.changeQuality(quality: .normal)
            } else if str == "QualityHeight" {
                ScreenRecorder.sharedInstance.rtmp.changeQuality(quality: .height)
            } else if str == "QualityHeightMovie" {
                ScreenRecorder.sharedInstance.rtmp.changeQuality(quality: .movie)
            }
        } else if let screenID = menuItem.representedObject as? CGDirectDisplayID {
            if screenID == CGMainDisplayID() {
                print("select mainScreen :\(screenID)")
            } else {
                print("select screen:\(screenID)")
            }
            ScreenRecorder.sharedInstance.changeScreen(displayID: screenID)
        }
    }
    
    @objc fileprivate func showPopover() {
        if let statusBarButton = item.button {
            popOver?.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: NSRectEdge.maxY)
        }
        
    }

}



