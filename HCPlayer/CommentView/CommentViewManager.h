//
//  CommentViewManager.h
//  Wutong
//
//  Created by HUANGXUTAO on 15/7/28.
//  Copyright (c) 2015年 HUANGXUTAO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <hccoren/base.h>
#import <hccoren/cmd.h>
#import <HCBaseSystem/PublicEnum.h>
#import "UICommentItemView.h"
#import "UICommentListView.h"

#define COMMENTVIEW_TAG 9201
#define COMMENTVIEW_HEIGHT 40
#define COMMENTVIEW_WIDTH 250

typedef void (^didGetComments) (int code,long commentsCount,NSString * qaguid,NSString * errorMsg);
typedef void (^didClearComments) (void);
typedef void (^didSendComment) (HCCallbackResult *result,long commentsCount,NSString * qaguid);
typedef void (^didRefreshComments) (int code);

//评论显示模式
enum _CommentShowType {
    CommentShowTypeList = 0,//List模式，自动弹出
    CommentShowTypePop = 1 //弹幕，全屏自动
};
typedef u_int8_t  CommentShowType;

@interface CommentViewManager : NSObject<UICommentListViewDelegate,UIScrollViewDelegate>
{
    NSMutableArray * commentList_;
    HCObjectType objectType_;
    long objectID_;
    int pageIndex_;
    
    BOOL scrollByProgram_;
    BOOL commentScrollByUser_;
    int commentScrollByUserSeconds_;
    BOOL refreshCommentView_;
    
    BOOL commentNeedReload_;
    BOOL isGoing_;
    CGFloat lastSecconds_;
    NSInteger lastIndex_;
    BOOL hasMoreComments_;

    CGFloat currentDuranceWhen_;
    CGFloat commentBeginWhen_;
    
    CGRect orgListViewFrame_;
    
    int commentsTotalCount_;
    
    BOOL timerDoing_;//是否正在按时处理
}
@property (nonatomic,PP_STRONG) UICommentsView * commentListView_;
@property (nonatomic,PP_STRONG) NSTimer * commentHideTimer_;
@property (nonatomic,assign) CommentShowType showType;


- (void)setObject:(HCObjectType)objectType objectID:(long)objectID;
- (void)setCurrentDuranceWhen:(CGFloat)seconds;
- (void)reset;
- (BOOL)isHidden;
- (void)readyToRelease;

- (UICommentsView*)  createCommentsView:(CGRect)frame;
- (NSInteger)           addComment:(Comment *)item;
- (void)                clearComments:(didClearComments)completed;

//- (void)                didCommentsScrolled:(UIScrollView *)scrollView;

- (void)show:(BOOL)animates;
- (void)hide:(BOOL)animates;
- (void)commentsShowInThread:(CGFloat)progress time:(CGFloat)seconds animate:(BOOL)animate;
- (void)commentsShow:(CGFloat)progress time:(CGFloat)seconds animate:(BOOL)animate;

- (void)refreshCommentsViewInThread:(BOOL)full reset:(BOOL)reset andIndex:(NSInteger)index;
- (void)refreshCommentsView:(BOOL)full reset:(BOOL)reset andIndex:(NSInteger)index;
- (void)startCommentTimer;
- (void)stopCommentTimer;
- (void)decCommentShowSecond:(NSTimer *)timer;

- (void)showCommentDetail:(NSIndexPath *)indexPath;

- (int)commentCount;
//- (UIView*)commentView;
- (BOOL)sendComment:(Comment *) comment completed:(didSendComment)completed;
- (void)getMtvComments:(long)mtvID pageSize:(int)pageSize pageIndex:(int)pageIndex completed:(didGetComments)completed;
- (void)getComments:(int)pageIndex completed:(didGetComments)completed;
- (void)setCommentBeginWhen:(CGFloat)durance;

- (void)refreshCommentsView:(CGFloat)durance reloadNow:(BOOL)reloadNow completed:(didRefreshComments)completed;
@end
