//
//  UICommentsPopView.h
//  maiba
//
//  Created by HUANGXUTAO on 15/8/24.
//  Copyright (c) 2015年 seenvoice.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <hccoren/base.h>
#import "CommentAnimateItem.h"
#import "UICommentsView.h"

//用于显示弹幕的形式，从右侧向左侧滑入
@interface UICommentsPopView : UICommentsView
{
    NSMutableArray * lineRights;
    NSMutableArray * lineTops;
}
@property (nonatomic,assign) int numberOfLines;//显示多少列数据
@property (nonatomic,assign) CGFloat itemSpace;//每条数据与前一条数据的最小距离
@end
