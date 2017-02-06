//
//  BaseCommand.swift
//  tubbX
//
//  Created by 陆广庆 on 2017/2/3.
//  Copyright © 2017年 陆广庆. All rights reserved.
//

import Cocoa

class BaseCommand: NSObject {

    var caller = ""
    
    init(_ caller: String) {
        super.init()
        self.caller = caller
    }
    
    func deviceSerialNumber() -> String {
        var serialNumber = ""
        let platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        
        if (platformExpert != 0) {
            let serialNumberAsCFString: Unmanaged<AnyObject> = IORegistryEntryCreateCFProperty(platformExpert,kIOPlatformSerialNumberKey as CFString!, kCFAllocatorDefault, 0)
            serialNumber = serialNumberAsCFString.takeRetainedValue() as! String
            IOObjectRelease(platformExpert)
        }
        return serialNumber
    }
}
