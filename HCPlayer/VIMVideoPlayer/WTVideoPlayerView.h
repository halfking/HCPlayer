//
//  VideoPlayerView.h
//  Smokescreen
//
//  Created by Alfred Hanssen on 2/9/14.
//  Copyright (c) 2014-2015 Vimeo (https://vimeo.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <hccoren/base.h>

@class MTV;
@class LyricView;
@class UICommentsView;
@class CommentViewManager;

typedef void (^PlayerFrameChanged)(CGRect frame,NSURL * url);
typedef void (^generateCompletedByPlayer)(CMTime requestTime,UIImage* image);
typedef void (^generateFailureByPlayer)(CMTime requestTime,NSError * error);

@class WTVideoPlayer;
@class WTVideoPlayerView;
//@class WTVideoPlayerProgressView;

//@protocol WTVideoPlayerViewDatasource <NSObject>
//@optional
//-(NSInteger) videoPlayerView:(WTVideoPlayerView *)player itemCount:(NSInteger)section;
//-(AVPlayerItem*) videoPlayerView:(WTVideoPlayerView *)player getPlayerItemForIndex:(NSInteger)index;
//-(PlayerMediaItem*) videoPlayerView:(WTVideoPlayerView *)player getItemForIndex:(NSInteger)index;
//-(PlayerMediaItem*) videoPlayerView:(WTVideoPlayerView *)player getItemForTime:(CGFloat)secondsInTime;
//-(CMTime) videoPlayerView:(WTVideoPlayerView *)player getDuration:(CGFloat)secondsInTime;
//@end

@protocol WTVideoPlayerViewDelegate <NSObject>

@optional
- (void)videoPlayerViewIsReadyToPlayVideo:(WTVideoPlayerView *)videoPlayerView;
- (void)videoPlayerViewDidReachEnd:(WTVideoPlayerView *)videoPlayerView;
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView timeDidChange:(CGFloat)cmTime;
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView loadedTimeRangeDidChange:(float)duration;
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView didFailWithError:(NSError *)error;
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView didFailedToPlayToEnd:(NSError *)error;
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView pausedByUnexpected:(NSError *)error item:(AVPlayerItem *)playerItem;
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView autoPlayAfterPause:(NSError *)error item:(AVPlayerItem *)playerItem;
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView didStalled:(AVPlayerItem *)playerItem;
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView didTapped:(AVPlayerItem *)playerItem;
- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView beginPlay:(AVPlayerItem *)playerItem;
//- (WTVideoPlayerProgressView *)videPlayerView:(WTVideoPlayerView *)videoPlayerView buildProgress:(CGFloat)totalSeconds currentSeconds:(CGFloat)seconds;
@end

//static UIBackgroundTaskIdentifier bgTask_ =  0;
@interface WTVideoPlayerView : UIView
{
//    CommentViewManager * commentManager_;
    CGFloat secondsPlaying_;

}

@property (nonatomic,PP_WEAK) id<WTVideoPlayerViewDelegate> delegate;
//@property (nonatomic,PP_WEAK) id<WTVideoPlayerViewDatasource> datasource;

@property (strong, nonatomic) AVPlayerItem *playerItem;

@property (assign,nonatomic) CGRect mainBounds;
//@property (assign,nonatomic) BOOL isFull;
@property (assign,nonatomic) BOOL playing;
@property (assign,nonatomic) BOOL isFull;
@property (nonatomic,strong) NSString * playerItemKey;
@property (nonatomic, assign) BOOL isEcoCancellationMode;

@property (nonatomic,assign) BOOL cachingWhenPlaying;   //在播放时是否缓存文件

+ (instancetype)sharedWTVideoPlayerView;
- (id)initWithFrame:(CGRect) frame;

- (BOOL) canPlay;
- (void) play;
- (BOOL) play:(CGFloat)begin end:(CGFloat)end;
- (void) pause;
- (void) pauseWithCache;
- (BOOL) seek:(CGFloat)seconds accurate:(BOOL)accurate;
- (void) resetPlayer;

- (void) setVideoVolume:(float)volume;//值 0-1
- (CGFloat) getVideoVolumne;

- (void) changeCurrentPlayerItem:(AVPlayerItem *)item;
- (void) changeCurrentItemUrl:(NSURL *)url;
- (void) changeCurrentItemPath:(NSString *)path;
- (void) setItemOrgPath:(NSString *)orgPath;
- (BOOL) isCurrentPath:(NSString *)path;
- (BOOL) isCurrentMTV:(MTV*)mtvItem;
- (void) resetPlayItemKey;
- (NSURL *) getUrlFromString:(NSString *)urlString;

- (CGFloat) getSecondsEnd;
- (NSURL *) getCurrentUrl;
- (CMTime) duration;
- (CMTime) durationWhen;
- (UIImage *) captureImage;
- (void) showActivityView;

-(void) resizeViewToRect:(CGRect) frame andUpdateBounds:(bool) isupdate withAnimation:(BOOL)animation hidden:(BOOL)hidden  changed:(PlayerFrameChanged)changed;

- (void)readyToRelease;
 
- (void)setPlayerTransform:(CATransform3D)transform position:(CGPoint)position;
@end
