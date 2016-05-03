//
//  UICommentItemView.m
//  Wutong
//
//  Created by HUANGXUTAO on 15/7/28.
//  Copyright (c) 2015年 HUANGXUTAO. All rights reserved.
//

#import "UICommentItemView.h"
#import <UIKit/UIKit.h>
#import <HCBaseSystem/UIWebImageViewN.h>
#import <HCBaseSystem/comments_wt.h>
#import "UICommentsView.h"
#import "CommentAnimateItem.h"
#import "player_config.h"
@implementation UICommentItemView
@synthesize Data;
@synthesize backgroundView;
@synthesize staySeconds;
@synthesize delegate;
@synthesize row;
- (id)init
{
    if(self = [super init])
    {
//        showAvatar = YES;
    }
    return self;
}
//- (void)setStaySeconds:(int)staySecondsTemp
//{
//    if(staySeconds>5)
//    {
//        NSLog(@"error");
//    }
//    staySeconds = staySecondsTemp;
//}
- (BOOL)needHide:(CGFloat)playerSeconds
{
//    NSLog(@"row:%d,durationwhen:%0.1f p0:%0.1f p1:%0.1f p2:%0.1f",
////          row,staySeconds,
//          row,
//          Data.DuranceForWhen,
//          playerSeconds,
//          playerSeconds + SCROLLSTAY_SECONDS,
//          playerSeconds - STAY_SECONDS);
    if(Data.DuranceForWhen >= playerSeconds + SCROLLSTAY_SECONDS)
    {
        return YES;
    }
    else if(Data.DuranceForWhen < playerSeconds - STAY_SECONDS)
    {
        return YES;
    }
    else if(staySeconds ==0)
    {
        NSLog(@"stayseconds:%f",(float)staySeconds);
        return YES;
    }
    return NO;
}
- (void)decTimer:(CGFloat)playerSeconds
{
    if(self.alpha <=0)
    {
//        NSLog(@"data:%d stayseconds:%f alpha:%f",row,staySeconds,self.alpha);
        if(self.Data.DuranceForWhen >= playerSeconds - 1 && self.Data.DuranceForWhen <= playerSeconds + 2)
        {
            staySeconds = -1;
        }
        else if(staySeconds >0)
        {
             staySeconds = 0;
        }
        if(staySeconds==0 && self.superview)
        {
            self.hidden = YES;
//            [self removeFromSuperview];
        }
        return;
    }
    if(Data.DuranceForWhen >=playerSeconds + SCROLLSTAY_SECONDS)
    {
//        NSLog(@"duration not match: %0.1f <--> %0.1f",Data.DuranceForWhen,playerSeconds);
        if(self.alpha >0)
        {
            staySeconds = -1;
            if(delegate)
            {
                CommentAnimateItem * item = [CommentAnimateItem new];
                item.row = row;
                item.duration = 0.2;
                item.viewObject = self;
                item.animateType = CommentHide;
                [delegate addAnimateItem:item];
            }
        }
        return;
    }
    staySeconds --;
//     NSLog(@"dec timer data:%d stayseconds:%f alpha:%f",Data.QAID,staySeconds,self.alpha);
//    if(self.alpha >1)
//    {
//    NSLog(@"data:%d stayseconds:%f alpha:%f",Data.QAID,staySeconds,self.alpha);
//    }
    if(staySeconds ==0 && self.alpha >0)
    {
        if(delegate)
        {
            CommentAnimateItem * item = [CommentAnimateItem new];
            item.row = row;
            if(playerSeconds==NSNotFound)
            {
                item.duration = 0;
            }
            else
            {
                item.duration = 0.2;
            }
            item.viewObject = self;
            item.animateType = CommentHide;
            [delegate addAnimateItem:item];
        }
    }
}
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self initialize];
}
- (void)resetTimer
{
    staySeconds = 5;
    self.backgroundView.hidden = NO;
}
#pragma mark - buildView
- (void)buildView
{
    //    UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 200)];
    //    bgView.backgroundColor = COLOR_Q;
    //    bgView.alpha = 0.2;
    //    [self addSubview:bgView];
    
    if (showAvatar)
    {
        UIWebImageViewN *imageView = [[UIWebImageViewN alloc] initWithFrame:CGRectMake(0,(self.frame.size.height - 30)/2.0f,30,30)];
        [imageView setImageWithURLString:Data.Logo
                                   width:30
                                  height:30
                    placeholderImageName:@"list_photo.png"];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 15.0;
        [self addSubview:imageView];
        
        
        self.layer.borderColor = [COLOR_O CGColor];
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 15;
        self.layer.masksToBounds = YES;
    }
    
    CGFloat top = 2;
    CGFloat left = showAvatar ? 35 : 5;
    CGFloat fontSize = showAvatar ? 12.0f : 16.0f;
    UILabel *comment_view = [[UILabel alloc] initWithFrame:CGRectMake(left, top, MAX(self.frame.size.width - left -10,100), self.frame.size.height - top)];
    comment_view.font = [UIFont systemFontOfSize:fontSize];
    comment_view.text = [Data.Content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    comment_view.textColor = [self getCommentColor];
    comment_view.shadowOffset = CGSizeMake(0.5, 0.5);
    comment_view.shadowColor = COLOR_BB;
    comment_view.backgroundColor = [UIColor clearColor];
    comment_view.numberOfLines = 3;
    
    [self addSubview: comment_view];
    
}
- (void)setData:(Comment *)item  showAvatar:(BOOL)showAvatarP
{
    PP_RELEASE(Data);
    Data = PP_RETAIN(item);
    showAvatar = showAvatarP;
    staySeconds = 5;
    if (showAvatar)
    {
        self.backgroundView.hidden = NO;
    }
    else
    {
        self.backgroundView.hidden = YES;
    }
    [self buildView];
}

- (BOOL)isShowAvatar
{
    return showAvatar;
}


- (UIColor *)getCommentColor
{
    //设置字体颜色
    if (!commentColors_)
    {
        commentColors_ = [[NSArray alloc] initWithObjects:
                          [UIColor whiteColor],
                          UIColorFromRGB(0xffb1e9),// 弹幕红
                          UIColorFromRGB(0x91f2e6),// 弹幕绿
                          UIColorFromRGB(0xffdf85),// 弹幕黄
                          nil];
    }
    int randomIndex = arc4random()%4;
    if (Data.CreateUser == -1)
    {
        return [commentColors_ lastObject];
    }
    return [commentColors_ objectAtIndex:randomIndex];
}

#pragma mark - Override Methods
- (void)prepareForReuse {
    //    [super prepareForReuse];
    for (UIView * vItem in self.subviews) {
        [vItem removeFromSuperview];
    }
    //    [backgroundView removeFromSuperview];
    PP_RELEASE(backgroundView);
    staySeconds = 5;
    self.alpha = 1;
    [self initialize];
}

#pragma mark -  Private Methods
- (void)initialize {
    if(self.backgroundView)
    {
        self.backgroundView.frame = self.bounds;
    }
    else
    {
        backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundView.backgroundColor = COLOR_Q;
        backgroundView.alpha = 0.2;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:backgroundView];
    }
//    showAvatar = YES;
}
@end
