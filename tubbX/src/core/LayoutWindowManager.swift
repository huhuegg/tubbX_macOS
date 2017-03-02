//
//  LayoutWindowManager.swift
//  LiveScreen
//
//  Created by huhuegg on 2017/3/1.
//  Copyright © 2017年 陆广庆. All rights reserved.
//
import AppKit
import Cocoa

enum FlagState {
    case resize
    case drag
    case ignore
}

class LayoutWindowManager: NSObject {
    
    fileprivate var layoutWindowController:LayoutWindowController?
    
    //监听键盘功能按键操作
    fileprivate var flagChangedMonitor: AnyObject?
    //监听鼠标移动操作
    fileprivate var mouseMoveMonitor: AnyObject?

    //监听鼠标操作
    fileprivate var mouseOperateMonitor: AnyObject?
    
    //鼠标的最后停留位置
    fileprivate var lastMousePosition: CGPoint?
    
    //最后捕获的窗口的信息
    fileprivate var lastWindowInfo:WindowInfo?

    var state: FlagState = .ignore {
        didSet {
            if self.state != oldValue {
                self.addMouseMoveMonitor(self.state)
            }
        }
    }
    
    deinit {
        self.removeKeyboardMonitor()
        self.removeMouseMoveMonitor()
    }
    
    //布局窗口
    func layoutController() -> LayoutWindowController? {
        if self.layoutWindowController == nil {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            if let layoutWindowController = storyboard.instantiateController(withIdentifier: "LayoutWindowController") as? LayoutWindowController {
                self.layoutWindowController = layoutWindowController
                addKeyboardMonitor({ (state) in
                    self.state = state
                })
            }
        }
        return self.layoutWindowController
    }
    
    //MARK:- 监听键盘鼠标操作
    //监听键盘功能按键操作
    fileprivate func addKeyboardMonitor(_ state: @escaping (FlagState) -> Void) {
        print("开始监听键盘功能按键操作")
        //侦测键盘功能按键操作(capsLock, shift, control, option, command, numericPad, help, function)
        self.flagChangedMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { event in
            self.state = self.stateForFlags(event.modifierFlags)
        } as AnyObject?
    }
    
    //移除键盘监听
    fileprivate func removeKeyboardMonitor() {
        if let flagChangedMonitor = self.flagChangedMonitor {
            NSEvent.removeMonitor(flagChangedMonitor)
        }
        self.flagChangedMonitor = nil
    }
    
    //监听鼠标移动操作
    fileprivate func addMouseMoveMonitor(_ state: FlagState) {
        self.removeMouseMoveMonitor()
        
        switch state {
        case .resize:
            self.mouseMoveMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { _ in
                let point = self.currentMousePosition()
                
                if let lastPosition = self.lastMousePosition {
                    let mouseDelta = CGPoint(x: lastPosition.x - point.x, y: lastPosition.y - point.y)
                    self.resizeLayoutWindow(mouseDelta: mouseDelta)
                }
                
                self.lastMousePosition = point
                
                } as AnyObject?
        case .drag:
            self.mouseMoveMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { _ in
                let point = self.currentMousePosition()
                
                if let lastPosition = self.lastMousePosition {
                    let mouseDelta = CGPoint(x: lastPosition.x - point.x, y: lastPosition.y - point.y)
                    self.moveLayoutWindow(mouseDelta: mouseDelta)
                }
                
                self.lastMousePosition = point
                
                } as AnyObject?
        case .ignore:
            self.lastMousePosition = nil
        }
    }

    fileprivate func addMouseOperateMonitor() {
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown,.leftMouseUp,.leftMouseDragged]) { (event) in
            let point = event.locationInWindow
            let windowNumber = event.windowNumber
            
            switch event.type {
            case .leftMouseDown:
                if self.check(point: point, windowNumber: windowNumber) == nil {
                    if AppStatusItem.instance.panel != nil {
                        self.lastWindowInfo = nil
                    }
                }
            case .leftMouseUp:

                if let windowInfo = self.check(point: point, windowNumber: windowNumber) {
                    let mounsePoint = self.currentMousePosition()
                    var ref: AXUIElement?
                    AXUIElementCopyElementAtPosition(AXUIElementCreateSystemWide(), Float(mounsePoint.x), Float(mounsePoint.y), &ref)
                    
                    if let window = self.layoutWindowController?.window {
                        var size = window.frame.size
                        let cfSize:CFTypeRef = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!, &size)!;
                        
                        AXUIElementSetAttributeValue(ref!, kAXSizeAttribute as CFString, cfSize);
                    }
                    
                }
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
    
    //移除鼠标监听
    fileprivate func removeMouseMoveMonitor() {
        if let mouseMonitor = self.mouseMoveMonitor {
            NSEvent.removeMonitor(mouseMonitor)
        }
        self.mouseMoveMonitor = nil
    }
    
    //MARK:- 根据组合功能按键状态确定当前所要做的操作
    //操作状态变化
    fileprivate func stateForFlags(_ flags: NSEventModifierFlags) -> FlagState {
        let hasCtrl = flags.contains(.control)
        let hasOption = flags.contains(.option)
        let hasShift = flags.contains(.shift)
        
        if hasCtrl && hasOption && hasShift { //Ctrl+Option+Shift
            return .resize
        } else if hasCtrl && hasOption { //Ctrl+Option
            return .drag
        } else {
            return .ignore
        }
    }
    
    //修改窗口大小
    fileprivate func resizeLayoutWindow(mouseDelta: CGPoint) {
        //print("resizeLayoutWindow")
        guard let layoutWnd = self.layoutWindowController?.window else {
            return
        }
        let size = layoutWnd.frame.size
        let newSize = CGSize(width: size.width - mouseDelta.x, height: size.height + mouseDelta.y)
        let rect = NSRect(origin: layoutWnd.frame.origin, size: newSize)
        layoutWnd.setFrame(rect, display: true, animate: true)
    }
    
    //移动窗口位置
    fileprivate func moveLayoutWindow(mouseDelta: CGPoint) {
        //print("moveLayoutWindow")
        guard let layoutWnd = self.layoutWindowController?.window else {
            return
        }
        
        let position = layoutWnd.frame.origin
        let newPosition = CGPoint(x: position.x - mouseDelta.x, y: position.y + mouseDelta.y)
        let rect = NSRect(origin: newPosition, size: layoutWnd.frame.size)
        layoutWnd.setFrame(rect, display: true, animate: true)
    }


    //MARK:- 鼠标及位置相关
    func currentMousePosition() -> CGPoint {
        return CGEvent(source: nil)!.location
    }
    
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

