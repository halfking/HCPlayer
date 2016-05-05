//
//  HCPlayerWrapper(Play).h
//  HCPlayerTest
//
//  Created by HUANGXUTAO on 16/5/5.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCPlayerWrapper.h"

@class MTV;
@interface HCPlayerWrapper(Play)
- (void)    pauseItemWithCoreEvents;
- (void)    playItemWithCoreEvents:(CGFloat)seconds;
- (void)    playItemChangeWithCoreEvents:(NSString *)path
                                 orgPath:(NSString*)orgPath
                                     mtv:(MTV*)item
                            beginSeconds:(CGFloat);
- (void)    playItemChangeWithReady:(NSString *)path
                            orgPath:(NSString*)orgPath
                                mtv:(MTV*)item
                       beginSeconds:(CGFloat)beginSeconds;

- (void)    removePlayerInThread;
- (BOOL)    playRemoteFile:(MTV *)item
                      path:(NSString *)path
                  audioUrl:(NSString*)audioUrl
                   seconds:(CGFloat)seconds;
- (void)    playLocalFile:(MTV *)item
                     path:(NSString *)path
                 audioUrl:(NSString*)audioUrl
                  seconds:(CGFloat)seconds
                     play:(BOOL)play
;
@end
