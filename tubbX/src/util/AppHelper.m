//
//  AppHelper.m
//  MacRecorder
//
//  Created by huhuegg on 2017/2/17.
//  Copyright © 2017年 huhuegg. All rights reserved.
//

#import "AppHelper.h"
#import <AppKit/AppKit.h>
//#import "WindowInfo.h"



@implementation AppHelper
//+(NSArray)appWindows:(pid_t)appPid {
//    NSRunningApplication *app = [NSRunningApplication runningApplicationWithProcessIdentifier:appPid];
//    
//}
//
//+(NSArray *)appWindows:(NSRunningApplication *)app {
//    NSMutableArray *arr = [NSMutableArray new];
//    NSString *appName = [app localizedName];
//    pid_t appPID = [app processIdentifier];
//    //NSLog(@"I see application '%@' with pid '%d'", appName, appPID);
//    
//    AXUIElementRef appRef = AXUIElementCreateApplication(appPID);
//    CFArrayRef windowsArrRef = [AccessibilityWrapper windowsInApp:appRef];
//    if (!windowsArrRef || CFArrayGetCount(windowsArrRef) == 0) {
//    } else {
//        CFMutableArrayRef windowsArr = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, windowsArrRef);
//        for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
//  
//            AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] initWithApp:appRef window:CFArrayGetValueAtIndex(windowsArr, i)];
//            NSString *title = [aw getTitle];
//            NSSize size = [aw getCurrentSize];
//            NSPoint tl = [aw getCurrentTopLeft];
//
//            if ([title isEqualToString:@""]) continue;
//            
//            WindowInfo *info = [WindowInfo new];
//            info.title = title;
//            info.size = size;
//            info.point = tl;
//            [arr addObject:info];
//        }
//    }
//    return arr;
//}
//
//+(void)updateWindowsForApp:(int)appPID snap:(NSArray *)snapInfos {
//    AXUIElementRef appRef = AXUIElementCreateApplication(appPID);
//    CFArrayRef windowsArrRef = [AccessibilityWrapper windowsInApp:appRef];
//    if (!windowsArrRef || CFArrayGetCount(windowsArrRef) == 0) {
//    } else {
//        CFMutableArrayRef windowsArr = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, windowsArrRef);
//        for (NSInteger i = 0; i < CFArrayGetCount(windowsArr); i++) {
//            //NSLog(@" Printing Window: %@", [AccessibilityWrapper getTitle:CFArrayGetValueAtIndex(windowsArr, i)]);
//            NSString *title = [AccessibilityWrapper getTitle:CFArrayGetValueAtIndex(windowsArr, i)];
//            
//            if ([title isEqualToString:@""]) continue;
//            
//            
//            AccessibilityWrapper *aw = [[AccessibilityWrapper alloc] initWithApp:appRef window:CFArrayGetValueAtIndex(windowsArr, i)];
//            NSSize size = [aw getCurrentSize];
//            NSPoint tl = [aw getCurrentTopLeft];
//            
//            NSSize snapSize = [self sizeForWindow:snapInfos windowTitle:title];
//            NSPoint snapPoint = [self pointForWindow:snapInfos windowTitle:title];
//            
//            if (size.height != snapSize.height || size.width != snapSize.width) {
//                NSLog(@"窗口大小已变化，恢复至原窗口大小");
//                [aw resizeWindow:snapSize];
//            }
//            
//            if (tl.x != snapPoint.x || tl.y != snapPoint.y) {
//                NSLog(@"窗口位置已变化，恢复至原窗口位置");
//                [aw moveWindow:snapPoint];
//            }
//        }
//    }
//
//}
//
//+(BOOL)findTitleInWindows:(NSArray *)windows windowTitle:(NSString *)windowTitle {
//    for (WindowInfo *window in windows) {
//        if ([window.title isEqualToString:windowTitle]) {
//            return true;
//        }
//    }
//    return false;
//}
//
//+(NSSize)sizeForWindow:(NSArray *)windows windowTitle:(NSString *)windowTitle {
//    if ([self findTitleInWindows:windows windowTitle:windowTitle]) {
//        for (WindowInfo *window in windows) {
//            if ([window.title isEqualToString:windowTitle]) {
//                return window.size;
//            }
//        }
//    }
//    return NSZeroSize;
//}
//
//+(NSPoint)pointForWindow:(NSArray *)windows windowTitle:(NSString *)windowTitle {
//    if ([self findTitleInWindows:windows windowTitle:windowTitle]) {
//        for (WindowInfo *window in windows) {
//            if ([window.title isEqualToString:windowTitle]) {
//                return window.point;
//            }
//        }
//    }
//    return NSZeroPoint;
//}
//
@end

