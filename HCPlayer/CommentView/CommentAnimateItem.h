//
//  CommentAnimateItem.h
//  Wutong
//
//  Created by HUANGXUTAO on 15/8/3.
//  Copyright (c) 2015年 HUANGXUTAO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <hccoren/base.h>
#import <UIKit/UIKit.h>

enum _CommentAnimateType{
    CommentAdd = 0,
    CommentShow = 1,
    CommentHide = 2,
    CommentScroll = 3,
    CommentRemove = 4,
    CommentSlideIn = 5
};
typedef u_int16_t  CommentAnimateType;

@interface CommentAnimateItem : NSObject
@property (nonatomic,assign) NSInteger row;
@property (nonatomic,assign) CGFloat duration;
@property (nonatomic,assign) CommentAnimateType animateType;
@property (nonatomic,PP_STRONG) UIView * viewObject;
@end
