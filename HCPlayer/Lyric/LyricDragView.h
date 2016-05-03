//
//  LyricDragView.h
//  maiba
//
//  Created by seentech_5 on 15/11/17.
//  Copyright © 2015年 seenvoice.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LyricDragView;
@protocol LyricDragViewDelegate <NSObject>

@optional
- (void)lyricDragViewWillBeginDragging:(LyricDragView *)lyricDragView;
- (void)lyricDragViewDidScroll:(LyricDragView *)lyricDragView second:(CGFloat)second;
- (void)lyricDragViewDidEndDecelerating:(LyricDragView *)lyricDragView second:(CGFloat)second;

- (void)lyricDragViewWillHide:(LyricDragView *)lyricDragView;
- (void)lyricDragViewWillBeginSingBack:(LyricDragView *)lyricDragView;
- (void)lyricDragViewdidSingBack:(LyricDragView *)lyricDragView atSecond:(CGFloat)second;


@end

@interface LyricDragView : UIView

@property(nonatomic,assign) BOOL isSample;
@property(nonatomic,assign) BOOL isPreviewing;
@property (nonatomic,weak) id<LyricDragViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame lyricViewSize:(CGSize)lyricViewSize;

- (void)setLyricDataWithLyricArray:(NSArray *)lyricArray timeArray:(NSArray *)timeArray;
- (void)setCurrentSecond:(CGFloat)second;
- (void)setMaxEnabledRow:(CGFloat)second;

- (void)endDecelerate;
// - (void)reloadData;

@end
