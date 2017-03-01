//
//  WindowInfoHelper.swift
//  tubbX
//
//  Created by huhuegg on 2017/2/21.
//  Copyright © 2017年 陆广庆. All rights reserved.
//

import Cocoa
import AppKit
import ApplicationServices

class WindowInfo:NSObject {
    var appPid:NSNumber!
    var appName:String!
    
    var windowNumber:NSNumber!
    var windowName:String!
    var windowBounds:NSRect!
    var windowIsOnScreen:NSNumber!
    var windowLayer:NSNumber!
    var windowAlpha:NSNumber!
    var windowStoreType:NSNumber!
    var windowSharingState:NSNumber!
    var windowMemoryUsage:NSNumber!
    
    init(appPid:NSNumber, appName:String, windowNumber:NSNumber, windowName:String, windowBounds:NSRect, windowIsOnScreen:NSNumber, windowLayer:NSNumber, windowAlpha:NSNumber, windowStoreType:NSNumber, windowSharingState:NSNumber, windowMemoryUsage:NSNumber) {
        super.init()
        self.appPid = appPid
        self.appName = appName
        self.windowNumber = windowNumber
        self.windowName = windowName
        self.windowBounds = windowBounds
        self.windowIsOnScreen = windowIsOnScreen
        self.windowLayer = windowLayer
        self.windowAlpha = windowAlpha
        self.windowStoreType = windowStoreType
        self.windowSharingState = windowSharingState
        self.windowMemoryUsage = windowMemoryUsage
    }
}


fileprivate let mjWindowManager:MJWindowManager = MJWindowManager()
class MJWindowManager: NSObject {
    static var instance: MJWindowManager {
        return mjWindowManager
    }
    
    fileprivate var timer:Timer?
    fileprivate var windowList:Array<WindowInfo> = Array()
    fileprivate var watchWindow:WindowInfo?
    
    fileprivate func listOptions() -> CGWindowListOption {
        let options = CGWindowListOption(arrayLiteral: CGWindowListOption.excludeDesktopElements, CGWindowListOption.optionOnScreenOnly)
        return options
    }
    
    override init() {
        super.init()
        updateWindowList()
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateWindowList), userInfo: nil, repeats: true)
        }
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(self.applicationChanged), name: NSNotification.Name.NSWorkspaceDidActivateApplication, object: nil)
    }
    
    deinit {
        NSWorkspace.shared().notificationCenter.removeObserver(self)
    }
    
    func allWindowList() -> Array<WindowInfo> {
        return windowList
    }
    
    func isWatchAppWindow() -> Bool {
        return self.watchWindow == nil ? false:true
    }
    
    func isAppWatched(windowInfo:WindowInfo) -> Bool {
        if isWatchAppWindow() {
            if self.watchWindow?.appName == windowInfo.appName {
                return true
            }
        }
        return false
    }
    
    func isWindowWatched(windowInfo:WindowInfo) -> Bool {
        if isWatchAppWindow() {
            if self.watchWindow?.appPid.intValue == windowInfo.appPid.intValue && self.watchWindow?.windowNumber.intValue == windowInfo.windowNumber.intValue {
                return true
            }
        }
        return false
    }
    
    func watch(windowInfo:WindowInfo?) {
        self.watchWindow = windowInfo
        ScreenRecorder.sharedInstance.changeWantedRect()
    }
    
    func watchedRect() -> NSRect {
        if var screens = NSScreen.screens() {
            var watchScreen:NSScreen?
            for screen in screens {
                let displayID = screen.deviceDescription["NSScreenNumber"] as! CGDirectDisplayID
                if displayID == ScreenRecorder.sharedInstance.lastDisplayID() {
                    watchScreen = screen
                }
            }

            if let _ = watchScreen {
                if let _ = watchWindow {
                    //供截取部分屏幕时，坐标系需要转换
                    let rect = CGRect(x: watchWindow!.windowBounds.origin.x, y: watchScreen!.frame.size.height - watchWindow!.windowBounds.size.height - watchWindow!.windowBounds.origin.y, width: watchWindow!.windowBounds.size.width, height: watchWindow!.windowBounds.size.height)
                    return rect
                    
                } else {
                    return watchScreen!.frame
                }
            } else {
                print("watchScreen is nil")
            }
            
        }
        
        return NSZeroRect
    }
    
    func activeApplicationAndWathchWindow(windowInfo:WindowInfo?) {
        if let _ = windowInfo {
            if windowInfo!.appPid.intValue > 1 {
                if let app = NSRunningApplication(processIdentifier: pid_t(windowInfo!.appPid.intValue)) {
                    print("在运行中的应用列表中查询到了需要激活的应用")
                    if !app.isActive {
                        print("isNotActive")
                        app.activate(options: NSApplicationActivationOptions.activateAllWindows)
                        if app.isHidden {
                            print("isHidden")
                            app.unhide()
                        }
                    }
                }
            }
        }
        self.watch(windowInfo: windowInfo)
    }
    
    func findApp(appPid:Int) -> NSRunningApplication? {
        let pid = pid_t(appPid)
        return NSRunningApplication.init(processIdentifier: pid)
    }
    
    func appWindows(appPid:Int) -> [AXUIElement]? {

        
        let pid = pid_t(appPid)
        let appRef:AXUIElement = AXUIElementCreateApplication(pid)
        let windowList : UnsafeMutablePointer<AnyObject?> = UnsafeMutablePointer<AnyObject?>.allocate(capacity: 1)

        AXUIElementCopyAttributeValue(appRef, "AXWindows" as CFString, windowList)
        if let list = windowList as? [AXUIElement] {
            print("window count:\(list.count)")
            return list
        } else {
            print("not found any window")
            return nil
        }
//        
//        return windowList.memory as! [AXUIElement]
//        
//        if (AXUIElementCopyAttributeValues(appRef, "AXWindows" as CFString, 0, 100, windowList) == 0) {
//            print("app window count:\(CFArrayGetCount(windows))")
//        }
//        
////        let error = AXUIElementCopyAttributeValue(appElement, kAXWindowAttribute as CFString, windowsRef)
////        print("app window count:\(CFArrayGetCount(windowsRef))")
////        if CFArrayGetCount(windowsRef) > 0 {
////            
////        }
////        if let _ = windowsRef {
////            let windowsArr:CFMutableArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, windowsRef);
////        }
////        
////        CFArrayRef _windows;
////        if (AXUIElementCopyAttributeValues(app, kAXWindowsAttribute, 0, 100, &_windows) == kAXErrorSuccess) {
////            return _windows;
////        }
////        
////        
////        AXUIElementRef appRef = AXUIElementCreateApplication(appPID);
////        CFArrayRef windowsArrRef = [AccessibilityWrapper windowsInApp:appRef];
////        if (!windowsArrRef || CFArrayGetCount(windowsArrRef) == 0) continue;
////        CFMutableArrayRef windowsArr = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, windowsArrRef);
////        NSArray *windowSnapshots = [[snapshot apps] objectForKey:appName];
////        // Check windows
////        for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
////            SlateLogger(@" Checking Window: %@", [AccessibilityWrapper getTitle:CFArrayGetValueAtIndex(windowsArr, i)]);

    }
    
    func find(windowNumber:Int) -> WindowInfo? {
        for info in windowList {
            if info.windowNumber.intValue == windowNumber {
                return info
            }
        }
        return nil
    }
    
    func isPointInWindow(point:NSPoint, windowNumber:Int, catchRect:NSRect) -> WindowInfo? {
        if let windowInfo = find(windowNumber: windowNumber) {
            if (point.x >= catchRect.origin.x && point.x <= catchRect.origin.x + catchRect.size.width) && (point.y >= catchRect.origin.y && point.y <= catchRect.origin.y + catchRect.size.height) {
                return windowInfo
            }
        }
        return nil
    }
}

extension MJWindowManager {
    @objc fileprivate func updateWindowList() {
        print("updateWindowList")
        var arr:Array<WindowInfo> = Array()
        var screenRect = CGRect.zero
        guard let screens = NSScreen.screens() else {
            return
        }
        for screen in screens {
            let displayID = screen.deviceDescription["NSScreenNumber"] as! CGDirectDisplayID
            if displayID == ScreenRecorder.sharedInstance.lastDisplayID() {
                screenRect = screen.frame
            }
        }

        let screenInfo = WindowInfo(appPid: -1, appName: "Screen", windowNumber: -1, windowName: "Screen", windowBounds: screenRect, windowIsOnScreen: -1, windowLayer: -1, windowAlpha: -1, windowStoreType: -1, windowSharingState: -1, windowMemoryUsage: -1)
        arr.append(screenInfo)
        
        if let windowListInfo = CGWindowListCopyWindowInfo(listOptions(), kCGNullWindowID) as? NSArray {
            for tmpWindowInfo in windowListInfo {
                if let info = tmpWindowInfo as? Dictionary<String,AnyObject> {
                    let appPid = info[kCGWindowOwnerPID as String] as! NSNumber
                    let appName = info[kCGWindowOwnerName as String] == nil ? "Unknown App":info[kCGWindowOwnerName as String] as! String
                    let windowNumber = info[kCGWindowNumber as String] as! NSNumber
                    let windowName = info[kCGWindowName as String] == nil ? "Unknown Window":info[kCGWindowName as String] as! String
                    
                    let tmpRect = info[kCGWindowBounds as String] as! Dictionary<String,AnyObject>
                    let x = tmpRect["X"] as! NSNumber
                    let y = tmpRect["Y"] as! NSNumber
                    let width = tmpRect["Width"] as! NSNumber
                    let height = tmpRect["Height"] as! NSNumber
                    
                    let windowBounds = NSMakeRect(CGFloat(x), CGFloat(y), CGFloat(width), CGFloat(height))
                    
                    
                    let windowIsOnScreen = info[kCGWindowIsOnscreen as String] as! NSNumber
                    let windowLayer = info[kCGWindowLayer as String] as! NSNumber
                    let windowAlpha = info[kCGWindowAlpha as String] as! NSNumber
                    let windowStoreType = info[kCGWindowStoreType as String] as! NSNumber
                    let windowSharingState = info[kCGWindowSharingState as String] as! NSNumber
                    let windowMemoryUsage = info[kCGWindowMemoryUsage as String] as! NSNumber
                    
                    let windowInfo = WindowInfo(appPid: appPid, appName: appName, windowNumber: windowNumber, windowName: windowName, windowBounds: windowBounds, windowIsOnScreen: windowIsOnScreen, windowLayer: windowLayer, windowAlpha: windowAlpha, windowStoreType: windowStoreType, windowSharingState: windowSharingState, windowMemoryUsage: windowMemoryUsage)
                    arr.append(windowInfo)
                    //print("app:\(windowInfo.appName!) window:\(windowInfo.windowName!) windowNumber:\(windowNumber)")
                }
                
            }
        }
        arr.sort { (a, b) -> Bool in
            return a.appPid.intValue < b.appPid.intValue //pidshen
        }

        windowList = arr
        checkWatchWindow()
    }
    
    fileprivate func checkWatchWindow() {
        if let watchInfo = self.watchWindow {
            if let info = find(appPid: watchInfo.appPid.intValue, windowNumber: watchInfo.windowNumber.intValue) {
                if info.windowBounds != watchInfo.windowBounds {
                    print("watchWindow bounds changed!")
                    
                    self.watchWindow = info
                    ScreenRecorder.sharedInstance.changeWantedRect()
                }
            } else {
                print("watchWindow is closed!")
                self.watchWindow = nil
                ScreenRecorder.sharedInstance.changeWantedRect()
            }
        }
    }
    
    private func find(appPid:Int, windowNumber:Int) -> WindowInfo? {
        for info in windowList {
            if info.appPid.intValue == appPid && info.windowNumber.intValue == windowNumber {
                return info
            }
        }
        return nil
    }
    
    @objc fileprivate func applicationChanged() {
        print("applicationChanged")
//        if let frontApp = NSWorkspace.shared().frontmostApplication {
//            if let _ = watchWindow {
//                if Int(frontApp.processIdentifier) == self.watchWindow!.appPid.intValue {
//                    ScreenRecorder.sharedInstance.changeWantedRect()
//                }
//            } else {
//                ScreenRecorder.sharedInstance.changeWantedRect()
//            }
//            
//        }
    }
    
    
}

