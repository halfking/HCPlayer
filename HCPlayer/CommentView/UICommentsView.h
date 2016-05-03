//
//  UICommentsView.h
//  maiba
//
//  Created by HUANGXUTAO on 15/8/24.
//  Copyright (c) 2015年 seenvoice.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <hccoren/base.h>

@class UICommentItemView;
@class UICommentsView;
@class CommentAnimateItem;

@protocol UICommentListViewDelegate
- (NSInteger)commentListView:(UICommentsView *)listView numberOfItemsInSection:(NSInteger)section;
- (CGSize)commentListView:(UICommentsView *)listView sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (UICommentItemView *)commentListView:(UICommentsView *)listView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)commentListView:(UICommentsView *)listView didEndDisplayCell:(NSIndexPath *)indexPath;
@optional
- (CGFloat)commentListView:(UICommentsView *)listView duranceForWhenForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)commentListView:(UICommentsView *)listView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface UICommentsView : UIScrollView
{
@protected
    NSMutableDictionary * cells_;
    NSMutableSet * cellsPool_;
    NSMutableDictionary * sizeSet_;
    
    BOOL isScrolling_;
    NSTimer * scrollTimer_;
    
    NSInteger totalCount_;
    
    NSMutableArray * animatesArray_;
    
    NSTimer * animateTimer_;
    NSInteger lastRow_;
    BOOL animatesDoing_;//正在动画中
    
    //animates
    CGFloat offsetTarget_;
    CGFloat offsetBegin_;
    CGFloat offsetEnd_;
    double scrollDuration_;
    CGFloat scrollTimeBegin_;
}

@property (nonatomic,PP_WEAK) NSObject <UICommentListViewDelegate> * dataSource;
@property (nonatomic,assign) CGFloat leftMargin;
@property (nonatomic,assign) CGFloat rightMargin;
@property (nonatomic,assign) CGFloat topMargin;
@property (nonatomic,assign) CGFloat bottomMargin;
@property (nonatomic,assign) CGFloat verticalSpace;
@property (nonatomic,assign) NSInteger initItemIndex;
@property (nonatomic,assign,readonly) CGFloat scrollOffset;
@property (nonatomic,assign) BOOL scrollByUser;
@property (nonatomic,assign) CGFloat playerDuration;
- (NSArray *)visibleItemViews;
- (NSArray *)visibleItemViewsWithoutZeroAlpha;
- (void)    updateScrollViewDimensions;
- (void)    setScrollOffset:(CGFloat)scrollOffset updateLayout:(BOOL)updateLayout;

//- (CGSize)  sizeForRow: (long)row;
//- (UIView *)viewForRow: (long)row;
//- (void)    decTimer:   (long)row;

- (UICommentItemView *)dequeueReusableCellWithReuseIdentifier:(NSString*) cellIdentifier forIndexPath:(NSIndexPath *)indexPath;
- (void)reloadData;
- (void)setDefault;
- (void)reset;
- (void)clearCache;//清空所有缓存
- (void)removeCache:(NSInteger)index;//清空某行及其后所有行的Rect缓存
- (CGFloat)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;
- (CGFloat)scrollByOffsetInThread:(CGFloat)offset duration:(NSTimeInterval)duration;
//- (void)hideItemsOutScrollView;

- (void)addAnimateItem:(CommentAnimateItem *)item;
- (void)clearAnimateItems;
- (void)doAnimates:(NSTimer *)timer;

#pragma mark - protected functions
- (void)updateLayout;
- (void)removeViewItem:(UIView *)view row:(NSInteger)row animates:(BOOL)animates
;
- (void)showViewItem:(UIView *)view row:(NSInteger)row animates:(BOOL)animates;
- (void)hideViewItem:(UIView *)view row:(NSInteger)row animates:(BOOL)animates
;
- (void)addViewItem:(UIView *)view row:(NSInteger)row animates:(BOOL)animates
;
@end
