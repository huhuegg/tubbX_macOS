//
//  AppHelper.h
//  MacRecorder
//
//  Created by huhuegg on 2017/2/17.
//  Copyright © 2017年 huhuegg. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CoreFoundation/CoreFoundation.h>
//
//#import "AccessibilityWrapper.h"

@interface AppHelper : NSObject
+(void)updateWindowsForApp:(int)appPID windowNumber:(int)windowNumber x:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height;
@end
