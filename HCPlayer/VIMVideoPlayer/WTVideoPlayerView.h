
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <hccoren/base.h>
#import <HCMVManager/HCPlayerSimple.h>
typedef void (^PlayerFrameChanged)(CGRect frame,NSURL * url);
typedef void (^generateCompletedByPlayer)(CMTime requestTime,UIImage* image);
typedef void (^generateFailureByPlayer)(CMTime requestTime,NSError * error);

//@class WTVideoPlayerView;

//@protocol WTVideoPlayerViewDelegate <NSObject>
//
//@optional
//- (void)videoPlayerViewIsReadyToPlayVideo:(WTVideoPlayerView *)videoPlayerView;
//- (void)videoPlayerViewDidReachEnd:(WTVideoPlayerView *)videoPlayerView;
//- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView timeDidChange:(CGFloat)cmTime;
//- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView loadedTimeRangeDidChange:(float)duration;
//- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView didFailWithError:(NSError *)error;
//- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView didFailedToPlayToEnd:(NSError *)error;
//- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView pausedByUnexpected:(NSError *)error item:(AVPlayerItem *)playerItem;
//- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView autoPlayAfterPause:(NSError *)error item:(AVPlayerItem *)playerItem;
//- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView didStalled:(AVPlayerItem *)playerItem;
//- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView didTapped:(AVPlayerItem *)playerItem;
//- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView beginPlay:(AVPlayerItem *)playerItem;
//
//- (void)videoPlayerView:(WTVideoPlayerView *)videoPlayerView showWaiting:(BOOL)isShow;
////- (WTVideoPlayerProgressView *)videPlayerView:(WTVideoPlayerView *)videoPlayerView buildProgress:(CGFloat)totalSeconds currentSeconds:(CGFloat)seconds;
//@end

//static UIBackgroundTaskIdentifier bgTask_ =  0;
@interface WTVideoPlayerView : HCPlayerSimple
{
//    CommentViewManager * commentManager_;
//    CGFloat secondsPlaying_;
//    CGFloat playRate_;
}

//@property (nonatomic,PP_WEAK) id<WTVideoPlayerViewDelegate> delegate;
//@property (nonatomic,PP_WEAK) id<WTVideoPlayerViewDatasource> datasource;

//@property (strong, nonatomic) AVPlayerItem *playerItem;
//
//@property (assign,nonatomic) CGRect mainBounds;
////@property (assign,nonatomic) BOOL isFull;
//@property (assign,nonatomic) BOOL playing;
@property (assign,nonatomic) BOOL isFull;
//@property (assign,nonatomic) CGFloat secondsPlaying;
//@property (nonatomic,strong) NSString * playerItemKey;
@property (nonatomic, assign) BOOL isEcoCancellationMode;

@property (nonatomic,assign) BOOL cachingWhenPlaying;   //在播放时是否缓存文件

+ (instancetype)sharedWTVideoPlayerView;
- (id)initWithFrame:(CGRect) frame;

//- (BOOL) canPlay;
//- (void) play;
//- (BOOL) play:(CGFloat)begin end:(CGFloat)end;
//- (void) pause;
- (void) pauseWithCache;
//- (BOOL) seek:(CGFloat)seconds accurate:(BOOL)accurate;
//- (void) resetPlayer;

//- (void) setRate:(CGFloat)rate;
//
//- (void) setVideoVolume:(float)volume;//值 0-1
//- (CGFloat) getVideoVolumne;

//- (void) changeCurrentPlayerItem:(AVPlayerItem *)item;
//- (void) changeCurrentItemUrl:(NSURL *)url;
//- (void) changeCurrentItemPath:(NSString *)path;
- (void) setItemOrgPath:(NSString *)orgPath;
- (BOOL) isCurrentPath:(NSString *)path;
//- (BOOL) isCurrentMTV:(MTV*)mtvItem;
- (void) resetPlayItemKey;
//- (NSURL *) getUrlFromString:(NSString *)urlString;
//
//- (CGFloat) getSecondsEnd;
//- (NSURL *) getCurrentUrl;
//- (CMTime) duration;
//- (CMTime) durationWhen;
//- (UIImage *) captureImage;
//- (void) showActivityView;

//-(void) resizeViewToRect:(CGRect) frame andUpdateBounds:(bool) isupdate withAnimation:(BOOL)animation hidden:(BOOL)hidden  changed:(PlayerFrameChanged)changed;
//
//- (void)readyToRelease;
// 
//- (void)setPlayerTransform:(CATransform3D)transform position:(CGPoint)position;
@end
