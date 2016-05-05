//
//  HCPlayerWrapper(background).h
//  HCPlayerTest
//
//  Created by HUANGXUTAO on 16/5/5.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCPlayerWrapper.h"
#import <HCBaseSystem/SNAlertView.h>
/*后台播放相关的代码*/

@interface HCPlayerWrapper(background)<SNAlertViewDelegate>
- (void) setPlayBackInfo;
- (void) setMPNowPlayingInfo;
- (void) clearPlayBackinfo;

- (void) playerWillEnterBackground;
- (void) playerWillEnterForeground;
- (void) endBackgroundTask;

- (void) showNoticeForWWAN; //使用3G时的提醒
- (void) hideNoticeForWWAN;
@end
