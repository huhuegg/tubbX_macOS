//
//  WSClient.swift
//  tubbX
//
//  Created by 陆广庆 on 2017/2/6.
//  Copyright © 2017年 陆广庆. All rights reserved.
//

import Cocoa
import Starscream
import SwiftyJSON

fileprivate let wsClient = WSClient()

class WSClient: NSObject, WebSocketDelegate {

    var socket: WebSocket!
    var heartBeatTimer: Timer!
    var messages: [String] = []
    
    static var sharedInstance: WSClient {
        return wsClient
    }
    
    override init() {
        super.init()
        socket = WebSocket(url: URL(string: "ws://192.168.242.253:8020/remote_client")!)
        socket.delegate = self
    }
    
    
    func start() {
        messages = []
        socket.connect()
    }
    
    func stop() {
        socket.disconnect()
    }
    
    func sendMessage(message: String) {
        if socket.isConnected {
            socket.write(string: message)
        } else {
            messages.append(message)
        }
    }
    
    // MARK: - WebSocketDelegate
    func websocketDidConnect(socket: WebSocket) {
        Swift.print("websocketDidConnect")
        heartBeatTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(WSClient.heartBeat), userInfo: nil, repeats: true)
        if !messages.isEmpty {
            for m in messages {
                sendMessage(message: m)
            }
            messages.removeAll()
        }
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        Swift.print("websocketDidDisconnect:\(error?.localizedDescription)")
        if heartBeatTimer != nil && heartBeatTimer.isValid {
            heartBeatTimer.invalidate()
            heartBeatTimer = nil
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        if text == "1" {
            // 心跳不处理
            return
        }
        // 消息处理
        Swift.print("websocketDidReceiveMessage: \(text)")
        let json = JSON(parseJSON: text)
        var userInfo: [String : Any] = [:]
        if let command = json["command"].string {
            userInfo["command"] = command
            userInfo["ret_msg"] = json["ret_msg"].string
            userInfo["ret_code"] = json["ret_code"].intValue
            switch command {
            case "Register":
                userInfo["qr"] = json["qr"].string
            case "BindClient":
                userInfo["publishUrl"] = json["publishUrl"].string
            case "StartRecord":
                break
            case "StopRecord":
                break
            case "UnboundClient":
                userInfo["qr"] = json["qr"].string
                break
            default:
                break
            }
        }
        if !userInfo.isEmpty {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "NetworkResp"), object: nil, userInfo: userInfo)
        }
        
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        Swift.print("websocketDidReceiveData: \(data)")
    }
    
    func heartBeat() {
        if socket.isConnected {
            socket.write(string: "0")
        }
    }
    
}
