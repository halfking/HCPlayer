//
//  UICommentListView.h
//  Wutong
//
//  Created by HUANGXUTAO on 15/7/28.
//  Copyright (c) 2015年 HUANGXUTAO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <hccoren/base.h>
#import "CommentAnimateItem.h"
#import "UICommentsView.h"

//@class UICommentItemView;
//@class UICommentListView;

//@protocol UICommentListViewDelegate
//- (NSInteger)commentListView:(UICommentListView *)listView numberOfItemsInSection:(NSInteger)section;
//- (CGSize)commentListView:(UICommentListView *)listView sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
//- (UICommentItemView *)commentListView:(UICommentListView *)listView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)commentListView:(UICommentListView *)listView didEndDisplayCell:(NSIndexPath *)indexPath;
//@optional
//- (void)commentListView:(UICommentListView *)listView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
//
//@end
@interface UICommentListView : UICommentsView
{
}
////@property (nonatomic,PP_STRONG,readonly) NSArray * visibleCells;
//@property (nonatomic,PP_WEAK) NSObject <UICommentListViewDelegate> * dataSource;
//@property (nonatomic,assign) CGFloat leftMargin;
//@property (nonatomic,assign) CGFloat rightMargin;
//@property (nonatomic,assign) CGFloat topMargin;
//@property (nonatomic,assign) CGFloat bottomMargin;
//@property (nonatomic,assign) CGFloat verticalSpace;
//@property (nonatomic,assign) NSInteger initItemIndex;
//@property (nonatomic,assign,readonly) CGFloat scrollOffset;
//@property (nonatomic,assign) BOOL scrollByUser;
//@property (nonatomic,assign) CGFloat playerDuration;
//- (NSArray *)visibleItemViews;
//- (NSArray *)visibleItemViewsWithoutZeroAlpha;
//- (void)    updateScrollViewDimensions;
//- (void)    setScrollOffset:(CGFloat)scrollOffset updateLayout:(BOOL)updateLayout;
//
////- (CGSize)  sizeForRow: (long)row;
////- (UIView *)viewForRow: (long)row;
////- (void)    decTimer:   (long)row;
//
//- (UICommentItemView *)dequeueReusableCellWithReuseIdentifier:(NSString*) cellIdentifier forIndexPath:(NSIndexPath *)indexPath;
//- (void)reloadData;
//- (void)reset;
//- (void)clearCache;//清空所有缓存
//- (void)removeCache:(NSInteger)index;//清空某行及其后所有行的Rect缓存
//- (CGFloat)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;
////- (void)hideItemsOutScrollView;
//
//- (void)addAnimateItem:(CommentAnimateItem *)item;
//- (void)clearAnimateItems;
//- (void)doAnimates:(NSTimer *)timer;
@end
