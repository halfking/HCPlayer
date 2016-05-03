//
//  WTVideoPlayerView(Lyric).m
//  maiba
//
//  Created by HUANGXUTAO on 16/1/6.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import "WTVideoPlayerView(Lyric).h"
#import <hccoren/UIView+extension.h>
#import "CommentViewManager.h"
#import "UICommentListView.h"
#import "UICommentsPopView.h"

#import "LyricView.h"

@implementation WTVideoPlayerView(Lyric)
//- (CGFloat) showLyricForPlayItem:(MTV *)item seconds:(CGFloat)seconds
//{
//    if(!self.lyricView)
//    {
//        self init
//    }
//    [self initLyricInThread:item.Lyric];
//    float lastLrcTime = -1;
//    if(mplayer_ && [mplayer_ isCurrentMTV:item])
//    {
//        if(item.SampleID>0 && item.MTVID==0 && !hasPan_)
//        {
//            lastLrcTime = [self getPlayBeginSeconds:seconds];
//
//            if(lastLrcTime>0)
//            {
//                needCountDown_ = YES;
//            }
//        }
//    }
//    else if(item.MTVID>0)
//    {
//        [self resetCommentsView];
//    }
//    else //无mplayer时
//    {
//        if(seconds>0 && item.SampleID>0 && item.MTVID==0)
//        {
//            lastLrcTime = seconds;
//        }
//    }
//    if (hasPan_ && needAutoPlay_ && !isSeekedToBlank_) {
//        needCountDown_ = YES;
//    }
//    return lastLrcTime;
//}
- (void)showLyric:(NSString *)lyric singleLine:(BOOL)singleLine container:(UIView *)container
{
    if([NSThread isMainThread])
    {
        CGFloat height = 90;
        if (self.lyricView) {
            [self.lyricView setLyric:lyric singleRowShow:singleLine];
            [self.lyricView didPlayingWithSecond:0];
            if(container)
            {
                [self resetLyricFrame:container.frame];
            }
            else
            {
                [self resetLyricFrame:self.frame];
            }
        }
        else
        {
            CGRect containerFrame = self.frame;
            if(container)
            {
                containerFrame = container.frame;
            }
            CGRect frame = CGRectMake((containerFrame.size.width - 400)/2.0f, containerFrame.size.height - 12 - height, 400, height);
            if(frame.origin.x <10)
            {
                frame.size.width -= (10 - frame.origin.x )*2;
                frame.origin.x = 10;
            }
            self.lyricView = [[LyricView alloc] initWithFrame:frame lyric:lyric singleRowShow:singleLine];
            if(container)
            {
                [container addSubview:self.lyricView];
            }
            else
            {
                [self addSubview:self.lyricView];
            }
            self.lyricView.backgroundColor = [UIColor clearColor];
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self showLyric:lyric singleLine:singleLine container:container];
                       });
    }
}
- (void)resetLyricFrame:(CGRect)containerFrame
{
    
    if([NSThread isMainThread])
    {
        CGRect frame = CGRectMake((containerFrame.size.width - 400)/2.0f, containerFrame.size.height - 12 - self.frame.size.height, 400, self.frame.size.height);
        if(frame.origin.x <10)
        {
            frame.size.width -= (10 - frame.origin.x )*2;
            frame.origin.x = 10;
        }
        self.lyricView.frame = frame;
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self resetLyricFrame:containerFrame];
                       });
    }
}
- (void)showLyric
{
    if([NSThread isMainThread])
    {
        if(self.lyricView)
        {
            self.lyricView.hidden = NO;
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self showLyric];
                       });
    }
    
}
- (void)hideLyric
{
    if([NSThread isMainThread])
    {
        if(self.lyricView)
        {
            self.lyricView.hidden = YES;
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self hideLyric];
                       });
    }
    
}
- (void)removeLyric
{
    if([NSThread isMainThread])
    {
        [self.lyricView removeFromSuperview];
        self.lyricView = nil;
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self removeLyric];
                       });
    }
}

#pragma mark - comments
- (void)initComments:(UIView *)container textContainer:(UIView *)textContainer inputTag:(int)inputTag objectType:(HCObjectType) objectType objectID:(long)objectID
{
    NSLog(@"comment view container frame = %@",NSStringFromCGRect(container.bounds));
    if(!self.commentManager)
    {
        self.commentManager = [CommentViewManager new];
    }
    [self.commentManager setObject:objectType objectID:objectID];
    if(!self.commentTextInput)
    {
        CGRect textFrame = self.frame;
        if(textContainer)
        {
            textFrame = textContainer.frame;
        }
        textFrame.origin.y = textFrame.size.height *2;
        textFrame.origin.x = (textFrame.size.width - 202)/2.0f;
        textFrame.size.width = 202;
        textFrame.size.height = 34;
        
        self.commentTextInput = [[UITextField alloc] initWithFrame:textFrame];
        self.commentTextInput.tag = inputTag;
        self.commentTextInput.borderStyle = UITextBorderStyleRoundedRect;
        self.commentTextInput.returnKeyType = UIReturnKeySend;
        self.commentTextInput.enabled = YES;
        self.commentTextInput.delegate = [self traverseResponderChainForUIViewController];
        if(textContainer)
           [textContainer addSubview:self.commentTextInput];
        else
            [self addSubview:self.commentTextInput];
    }
    if(!self.commentListView)
    {
        CGRect frame = self.frame;
        if(container)
        {
            frame = container.bounds;
        }
        frame.origin.x = 0;
        frame.origin.y = 50;
        frame.size.height -= 100;
        self.commentManager.showType = CommentShowTypePop;
        self.commentListView = [self.commentManager createCommentsView:frame];
        self.commentListView.hidden = YES;
        //self.commentListView.backgroundColor = [UIColor yellowColor];
        if(container)
            [container addSubview:self.commentListView];
        else
            [self addSubview:self.commentListView];
    }
    [self refreshComment];
}
- (void)resetCommentsFrame:(CGRect)commentFamre container:(UIView *)container textContainer:(UIView *)textContainer
{
    if(self.commentTextInput)
    {
        CGRect textFrame = self.frame;
        if(textContainer)
        {
            textFrame = textContainer.frame;
        }
        textFrame.origin.y = textFrame.size.height *2;
        textFrame.origin.x = (textFrame.size.width - 202)/2.0f;
        textFrame.size.width = 202;
        textFrame.size.height = 34;
        
        self.commentTextInput.frame = textFrame;
    }
    if(self.commentListView)
    {
//        CGRect frame = self.frame;
//        if(container)
//        {
//            frame = container.bounds;
//        }
//        frame.origin.x = 0;
//        frame.origin.y = 50;
//        frame.size.height -= 100;
        CGRect frame = commentFamre;
        frame.origin.x = 0;
        frame.origin.y = 50;
        frame.size.height -= 100;
        self.commentListView.frame = frame;
        
        if(container) {
            if (self.commentListView.superview == container)
                [container bringSubviewToFront:self.commentListView];
            else
                [container addSubview:self.commentListView];
        }
        else {
            if (self.commentListView.superview == self)
                [self bringSubviewToFront:self.commentListView];
            else
                [self addSubview:self.commentListView];
        }
        [self refreshComment];
    }
}
- (void)showComments
{
    if(!self.commentListView || self.commentListView.hidden==NO) return;
    [self switchCommentsShowHide:YES];
}
- (void)hideComments
{
    if(!self.commentListView || self.commentListView.hidden) return;
    [self switchCommentsShowHide:NO];
}
- (void)resetComments
{
    if(self.commentManager)
    {
        [self.commentManager stopCommentTimer];
        [self.commentManager reset];
    }
    if(self.commentListView)
    {
        [self.commentListView reset];
    }
    if(self.commentTextInput)
    {
        self.commentTextInput.text = @"";
    }
}
- (void)removeComments
{
    if(self.commentManager)
    {
        [self.commentManager stopCommentTimer];
        [self.commentManager readyToRelease];
        self.commentManager = nil;
    }
    if(self.commentListView)
    {
        [self.commentListView removeFromSuperview];
        self.commentListView = nil;
    }
    if(self.commentTextInput)
    {
        [self.commentTextInput removeFromSuperview];
        self.commentTextInput = nil;
    }
}

#pragma mark - comments details
- (void)refreshCommentsView:(CGFloat)durance
{
    if(!self.commentManager) return;
    // 刷新评论到指定位置
//    [self.commentManager reset];
//    //        [self.commentManager setObject:HCObjectTypeMTV objectID:currentMtv_.MTVID];
//    [self.commentManager setCommentBeginWhen:durance];
//    [self.commentManager getComments:0 completed:^(int code,long commentsCount,NSString * qaguid,NSString * msg)
//     {
//         if(code==0 && self.commentListView)
//         {
//             [self switchCommentsShowHide:!self.commentListView.hidden];
//         }
//     }];
    
    [self.commentManager refreshCommentsView:durance reloadNow:YES completed:^(int code) {
        if (code == 0 && self.commentListView) {
            [self switchCommentsShowHide:!self.commentListView.hidden];
        }
    }];
}

//- (void)refreshComment
//{
//    CGFloat durance = 0;
//    CMTime cTime = self.durationWhen;
//    if(CMTIME_IS_VALID(cTime))
//    {
//        durance = CMTimeGetSeconds(cTime);
//    }
//    durance = (int)durance; // 保留时间为0时的情况
//    [self refreshCommentsView:durance];
//    NSLog(@"refreshCommentsView: %.1f",durance);
//}
- (void)refreshComment
{
    CGFloat durance = CMTimeGetSeconds(self.durationWhen);
    
    if (!(durance>0)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self refreshComment];
        });
    }
    else
    {
        durance = (int)durance; // 保留时间为0时的情况
        [self refreshCommentsView:durance];
        NSLog(@"refreshCommentsView: %.1f",durance);
    }
}

-(void)switchCommentsShowHide:(BOOL)Show
{
    if ([NSThread isMainThread]) {
        if(!Show) // 隐藏
        {
            self.commentListView.hidden = YES;
            [self.commentManager stopCommentTimer];
        }
        else // 显示
        {
            self.commentListView.hidden = NO;
            [self.commentManager startCommentTimer];
        }
        NSLog(@"listview frame:%@ hidden:%d",NSStringFromCGRect(self.commentListView.frame),self.commentListView.hidden);
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self switchCommentsShowHide:Show];
        });
        
    }
}
@end
