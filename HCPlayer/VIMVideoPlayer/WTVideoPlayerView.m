
#import "WTVideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>

#import "VDCLoaderConnectionN.h"
#import "VDCTempFileManagerN.h"
#import "VDCTempFileManagerN(readwriter).h"

@interface WTVideoPlayerView () <VDCLoaderConnectionNDelegate>
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) VDCLoaderConnectionN * loader;
@end

@implementation WTVideoPlayerView
{
//    int pauseCount_;//即检测到播放速率为0的次数
    CATransform3D transform_;
    CGPoint position_;
}
+ (instancetype)sharedWTVideoPlayerView
{
    return sharedPlayerViewNew;
}

+ (void)releaseSharedWTVideoPlayerView
{
    t = 0;
    if(sharedPlayerViewNew)
    {
        [sharedPlayerViewNew readyToRelease];
        sharedPlayerViewNew = nil;
    }
}

- (void)setPlayerTransform:(CATransform3D)transform position:(CGPoint)position
{
    transform_  = transform;
    position_ = position;
}


static dispatch_once_t t;
static WTVideoPlayerView *sharedPlayerViewNew = nil;


- (id)initWithFrame:(CGRect) frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        transform_ = CATransform3DIdentity;
        position_ = self.center;

        sharedPlayerViewNew = self;
    }
    return self;
}

- (void)resetPlayer
{
    [self pauseWithCache];
    [super resetPlayer];
}

- (void)pauseWithCache
{
    [self pause];
    if(self.loader)
    {
        [self.loader cancelWithClose];
    }
}

#pragma mark - change item
- (void)changeCurrentItemUrl:(NSURL *)url
{
    AVURLAsset *movieAsset = nil;
    NSLog(@"play item url:%@",[url absoluteString]);
    
    if ([HCFileManager isLocalFile:[url absoluteString]] || ([DeviceConfig IOSVersion] < 7.0) || self.cachingWhenPlaying==NO) {
        movieAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    }
    else
    {
        if(self.loader)
        {
            [self.loader cancel];
            self.loader = nil;
        }
        NSLog(@"create loader connection");
        self.loader = [[VDCLoaderConnectionN alloc]init];
        self.loader.delegate = self;
        NSURL *playUrl = [self.loader getSchemeVideoURL:url];
        //        NSURL * playUrl = url;
        NSLog(@"getschecme video url:%@",[url path]);
        movieAsset = [AVURLAsset URLAssetWithURL:playUrl options:nil];
        [movieAsset.resourceLoader setDelegate:self.loader queue:dispatch_get_main_queue()];
    }
    AVPlayerItem * playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    [self changeCurrentPlayerItem:playerItem];
    
    //回音消除相关代码
    //    if (url && [CommonUtil isLocalFile:[url absoluteString]]) {
    //        audioPlayerID_ = [[AudioCenter shareAudioCenter] initializeAudioPlayerWithURL:url];
    //    }
    
    currentPlayUrl_ = PP_RETAIN(url);
}
- (void)didFailLoadingWithTask:(VDCTempFileManagerN *)task WithError:(NSInteger )errorCode
{
    NSLog(@"load task failure:%ld",(long)errorCode);
}
- (void)didFinishLoadingWithTask:(VDCTempFileManagerN *)task
{
    if(self.playing==NO && needAutoPlay_==YES)
    {
        [self.player cancelPendingPrerolls];
        [self.player play];
    }
}
//-(void) changeCurrentItemPath:(NSString *)path
//{
//    NSURL * url = [self getUrlFromString:path];
//    [self changeCurrentItemUrl:url];
//}
//- (void)setItemOrgPath:(NSString *)orgPath
//{
//    PP_RELEASE(orgPath_);
//    orgPath_ = PP_RETAIN(orgPath);
//}

- (BOOL) isCurrentPath:(NSString *)path
{
    if(!path || path.length==0) return NO;
    if(self.key && [self.key isEqual:path])
        return YES;
    if(orgPath_ && [orgPath_ isEqualToString:path])
        return YES;
    //如果敀展名相同也可以的
    
    
    if(!currentPlayUrl_) return NO;
    
    NSString * fullPath = [[self getUrlFromString:path]absoluteString];
    if ([fullPath isEqual:currentPlayUrl_.absoluteString])
        return YES;
    else
        return NO;
}

#pragma mark - observer value
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
     if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
         AVPlayerItem *playerItem = (AVPlayerItem *)object;
        if (playerItem.playbackBufferEmpty)
        {
            [self pause];
            needAutoPlay_ = YES;
            if(self.loader)
            {
                [self.loader recheckLoad];
            }
            [self showActivityView];
            NSLog(@"player item playback buffer is empty");
        }
    }
   else
   {
       [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
   }
}

-(void)avPlayerPlaybackStalled:(NSNotification *)notification
{
    NSLog(@"media did not arrive in time to continue playback,stalled...........");
    
    needAutoPlay_ = YES;
    [self showActivityView];
    if(self.cachingWhenPlaying && self.loader)
    {
        NSInteger ret = [self.loader recheckLoad];
        if(ret ==0)
        {
            //重新构建Playeritem,重新开始
        }
        else
        {
            
        }
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(playerSimple:didStalled:)]){
        [self.delegate  playerSimple:self didStalled:notification.object];
    }
    
}

- (void)avPlayerItemTimeJumped:(NSNotification *)notification
{
    //    NSLog(@"the item's current time has changed discontinuously");
}


#pragma mark - init dealloc
- (void)readyToRelease
{
    [self pause];
    [_loader cancelWithClose];
    
    _loader.delegate = nil;
    _loader = nil;
    
    sharedPlayerViewNew = nil;
    
    [super readyToRelease];
}
- (void)dealloc
{
    NSLog(@"wtplayer dealloc...");
    [self readyToRelease];
    PP_SUPERDEALLOC;
}
@end
