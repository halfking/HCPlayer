//
//  MusicDetailViewController(Play).h
//  maiba
//
//  Created by seentech_5 on 15/12/18.
//  Copyright © 2015年 seenvoice.com. All rights reserved.
//

#import "MusicDetailViewController.h"

@interface MusicDetailViewController(Play)<WTVideoPlayerViewDelegate,WTVideoPlayerProgressDelegate>
//- (void)handleInterruption:(UInt32)inInterruptionState;

- (void) pauseItem:(id)sender;
- (BOOL) playItem:(id)sender seconds:(CGFloat)seconds;

- (void)pauseItemWithCoreEvents;
- (void)playItemWithCoreEvents:(CGFloat)seconds;
- (void)playItemChangeWithCoreEvents:(NSString *)path orgPath:(NSString*)orgPath mtv:(MTV*)item beginSeconds:(CGFloat)beginSeconds;
- (void)playItemChangeWithReady:(NSString *)path orgPath:(NSString*)orgPath mtv:(MTV*)item beginSeconds:(CGFloat)beginSeconds play:(BOOL)play;
- (BOOL) playRemoteFile:(MTV *)item path:(NSString *)path audioUrl:(NSString*)audioUrl seconds:(CGFloat)seconds;
- (void) playLocalFile:(MTV *)item path:(NSString *)path audioUrl:(NSString*)audioUrl seconds:(CGFloat)seconds play:(BOOL)play;

- (void)removePlayerInThread;

- (void) showNoticeForWWANForTag:(int)tagID;

- (void)playerWillEnterBackground;
- (void)playerWillEnterForeground;
- (void)endBackgroundTask;

- (CGFloat) currentPlayerWhen;
- (CGFloat) duration;
- (BOOL) isPlaying;

- (void)hidePlayerWaitingView;
- (BOOL)canPlay;
- (void)setPlayBackInfo;
- (void)setMPNowPlayingInfo;
- (void)clearPlayBackinfo;
@end
