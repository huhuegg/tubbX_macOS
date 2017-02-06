//
//  RegisterCommand.swift
//  tubbX
//
//  Created by 陆广庆 on 2017/2/6.
//  Copyright © 2017年 陆广庆. All rights reserved.
//

import Cocoa
import SwiftyJSON


class RegisterCommand: BaseCommand {

    func makeCommand() -> String {
        let serialNumber = deviceSerialNumber()
        let commandDict: [String : Any] = [
            "command" : "Register",
            "clientId" : serialNumber
        ]
        let json = JSON(commandDict)
        if let string = json.rawString() {
            return string
        }
        return ""
    }
    
     
}
