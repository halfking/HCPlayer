//
//  HCPlayerWrapper(Data).h
//  HCPlayerTest
//
//  Created by HUANGXUTAO on 16/5/5.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCPlayerWrapper.h"
@class MTV;

@interface HCPlayerWrapper(Data)
- (BOOL)    canPlay;
- (CGFloat) currentPlayerWhen;
- (CGFloat) duration;
- (BOOL)    isPlaying;
- (void)    setTotalSeconds:(CGFloat)seconds;
- (void)    updateFilePath:(MTV*)item filePath:(NSString*)filePath;
- (BOOL)    isFullScreen;
- (BOOL)    canShowRecordBtn;
- (BOOL)    currentItemIsSample;
- (BOOL)    isMVLandscape;
- (BOOL)    hasGuideAudio;

- (void)    showPlayerWaitingView;
- (void)    hidePlayerWaitingView;


- (void)recordPlayItemBegin;
- (void)recordPlayItemEnd;

@end
