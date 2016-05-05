//
//  WTVideoPlayerView(MTV).h
//  maiba
//
//  Created by HUANGXUTAO on 16/1/20.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <hccoren/base.h>
#import <HCBaseSystem/VDCItem.h>
#import <HCMVManager/MTV.h>
#import <HCBaseSystem/SNAlertView.h>
#import "WTVideoPlayerView.h"
#import <UIKit/UIKit.h>

@interface WTVideoPlayerView(MTV)<UIActionSheetDelegate>
//检查文件属性
+ (BOOL)isDownloadCompleted:(MTV **)orgItem Sample:(MTV*)sample NetStatus:(NetworkStatus)status UserID:(long)userID;
+ (VDCItem *)getVDCItem:(MTV*)item Sample:(MTV *)sample;
+ (void) stopCacheMTV:(MTV *)item;

- (BOOL) playMTV:(MTV *)item;
- (BOOL) pauseMTV;
@end
