//
//  QRCode.swift
//  tubbX
//
//  Created by 陆广庆 on 2016/12/21.
//  Copyright © 2016年 陆广庆. All rights reserved.
//

import Cocoa

class QRCode: NSObject {

    class func generateQRImage(from string: String, size: CGFloat) -> NSImage? {
        let data = string.data(using: String.Encoding.utf8)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            
            if let output = filter.outputImage {
                let extent = output.extent
                let scale = min(size / extent.width, size / extent.height)
                let transform = CGAffineTransform(scaleX: scale, y: scale)
                let result = output.applying(transform)
                let rep: NSCIImageRep = NSCIImageRep(ciImage: result)
                let nsImage: NSImage = NSImage(size: rep.size)
                nsImage.addRepresentation(rep)
                return nsImage
            }
        }
        
        return nil
    }
    
}
