//
//  AppEvent.swift
//  LiveScreen
//
//  Created by huhuegg on 2017/2/27.
//  Copyright © 2017年 陆广庆. All rights reserved.
//

import Cocoa

fileprivate let appEventInstance = AppEvent()
class AppEvent: NSObject {
    var lastWindowInfo:WindowInfo?
    
    static var instance: AppEvent {
        return appEventInstance
    }
    
    func addEvent() {
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown,.leftMouseUp,.leftMouseDragged]) { (event) in
            let point = event.locationInWindow
            let windowNumber = event.windowNumber
            
            switch event.type {
            case .leftMouseDown:
                if let windowInfo = self.check(point: point, windowNumber: windowNumber) {
                } else {
                    if let panel = AppStatusItem.instance.panel {
                        self.lastWindowInfo = nil
                    }
                }
            case .leftMouseUp:
                if let windowInfo = self.check(point: point, windowNumber: windowNumber) {
                    if self.lastWindowInfo == nil {
                        print("捕获到新窗口 pid:\(windowInfo.appPid.intValue) app:\(windowInfo.appName!) windowName:\(windowInfo.windowName!)")
                        self.lastWindowInfo = windowInfo
                        
                        if let app = NSRunningApplication(processIdentifier: pid_t(windowInfo.appPid.intValue)) {
                            let appRef = AXUIElementCreateApplication(app.processIdentifier)

                            var windowsArrRef:CFTypeRef?
                            if AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &windowsArrRef) == .success {
                                let windowArr = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, windowsArrRef as! CFArray!)

                                for window in windowsArr {
                                    if let w = window as? AXUIElement {
                                        dump(w)
                                    }
                                }
                                
                            }

                            
                            
                            
//                            print("pid:\(app.processIdentifier)   window count:\(app.windows.count)")
//                            dump(app.windows)
                        }
                        
//                        
//                        let windows = MJWindowManager.instance.appWindows(appPid: windowInfo.appPid.intValue)
//                        if let app = MJWindowManager.instance.findApp(appPid: windowInfo.appPid.intValue) {
//                            app
//                            
//                        }
                        
                        
//                        AppHelper.updateWindows(forApp: Int32(windowInfo.appPid.intValue), windowNumber: Int32(windowInfo.windowNumber.intValue), x: windowInfo.windowBounds.origin.x, y: windowInfo.windowBounds.origin.y, width: windowInfo.windowBounds.width, height: windowInfo.windowBounds.height)
                        
                    } else if self.lastWindowInfo!.windowNumber == windowInfo.windowNumber {
                        print("更新捕获窗口 app:\(windowInfo.appName!) windowName:\(windowInfo.windowName!)")
                    }
                }
                break
//            case .mouseMoved:
//                //print("mouseMoved")
//                break
            case .leftMouseDragged:
                if let windowInfo = self.check(point: point, windowNumber: windowNumber) {
                    if let panel = AppStatusItem.instance.panel {
                        panel.contentView?.wantsLayer = true
                        panel.contentView?.layer?.backgroundColor = NSColor.blue.cgColor
                    }
                } else {
                    if let panel = AppStatusItem.instance.panel {
                        panel.contentView?.wantsLayer = true
                        panel.contentView?.layer?.backgroundColor = NSColor.clear.cgColor
                        
                        self.lastWindowInfo = nil
                    }
                }
                break
            default:
                break
            }
        }
    }
}

extension AppEvent {
    
    /// 判断鼠标当前位置是否包含相关的WindowInfo信息
    ///
    /// - Parameters:
    ///   - point: 鼠标位置
    ///   - windowNumber: 事件的windowNumber
    /// - Returns: windowInfo
    fileprivate func check(point:NSPoint, windowNumber:Int) -> WindowInfo? {
        if let catchRect = AppStatusItem.instance.panel?.frame {
            if let windowInfo = MJWindowManager.instance.isPointInWindow(point: point, windowNumber: windowNumber, catchRect: catchRect) {
                
                return windowInfo
            }
        }
        return nil
    }
}
