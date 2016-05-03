//
//  UICommentItemView.h
//  Wutong
//
//  Created by HUANGXUTAO on 15/7/28.
//  Copyright (c) 2015年 HUANGXUTAO. All rights reserved.
//

#import <UIKit/UIKit.h>

#define STAY_SECONDS 5
#define SCROLLSTAY_SECONDS 3
@class  UICommentsView;
@class Comment;
@interface UICommentItemView : UIView
{
    BOOL showAvatar;
    NSArray *commentColors_;
}
@property (strong, nonatomic, readonly) UIView *backgroundView;
@property (nonatomic,strong,readonly) Comment * Data;
@property (nonatomic,assign) int staySeconds;
@property (nonatomic,assign) NSInteger row;
@property (nonatomic,weak) UICommentsView * delegate;
- (void)prepareForReuse;
- (void)decTimer:(CGFloat)playerSeconds;
- (void)resetTimer;
- (void)setData:(Comment *)item showAvatar:(BOOL)showAvatar;
- (BOOL)needHide:(CGFloat)playerSeconds;
@end
