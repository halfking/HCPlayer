
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <hccoren/base.h>
#import <HCMVManager/HCPlayerSimple.h>
typedef void (^PlayerFrameChanged)(CGRect frame,NSURL * url);
typedef void (^generateCompletedByPlayer)(CMTime requestTime,UIImage* image);
typedef void (^generateFailureByPlayer)(CMTime requestTime,NSError * error);


//static UIBackgroundTaskIdentifier bgTask_ =  0;
@interface WTVideoPlayerView : HCPlayerSimple

@property (assign,nonatomic) BOOL isFull;
@property (nonatomic, assign) BOOL isEcoCancellationMode;
@property (nonatomic,assign) BOOL cachingWhenPlaying;   //在播放时是否缓存文件

+ (instancetype)sharedWTVideoPlayerView;
- (id)initWithFrame:(CGRect) frame;

- (void) pauseWithCache;

- (void) setItemOrgPath:(NSString *)orgPath;
- (BOOL) isCurrentPath:(NSString *)path;

@end
