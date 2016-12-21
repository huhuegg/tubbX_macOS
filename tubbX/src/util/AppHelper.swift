//
//  AppHelper.swift
//  ECM_OSX
//
//  Created by 陆广庆 on 2016/10/20.
//  Copyright © 2016年 陆广庆. All rights reserved.
//

import Cocoa

class AppHelper: NSObject {

    
    class func deviceSerialNumber() -> String {
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
