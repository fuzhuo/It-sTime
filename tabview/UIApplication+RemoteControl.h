//
//  UIApplication+RemoteControl.h
//  tabview
//
//  Created by zfu on 6/22/16.
//  Copyright © 2016 zfu. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *kRemoteControlPlayTapped;
extern NSString *kRemoteControlPauseTapped;
extern NSString *kRemoteControlStopTapped;
extern NSString *kRemoteControlPreviousTapped;
extern NSString *kRemoteControlNextTapped;
extern NSString *kRemoteControlOtherTapped;


@interface UIApplication (RemoteControl)
- (void)observeRemoteControl:(id)observer selector:(SEL)selector;
- (void)removeRemoteControl:(id)observer selector:(SEL)selector;
@end
