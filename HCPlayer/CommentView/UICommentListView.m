//
//  UICommentListView.m
//  Wutong
//
//  Created by HUANGXUTAO on 15/7/28.
//  Copyright (c) 2015年 HUANGXUTAO. All rights reserved.
//

#import "UICommentListView.h"

#import "UICommentItemView.h"

@implementation UICommentListView
- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self setDefault];
    }
    return self;
}
- (void)setDefault
{
    [super setDefault];
}

- (void)dealloc
{    
    PP_SUPERDEALLOC;
}

#pragma mark -
#pragma mark View management
- (CGRect)getFrameForIndex:(NSInteger)index
{
    CGRect lastFrame = CGRectZero;
    if([sizeSet_ objectForKey:[NSNumber numberWithInteger:index]])
    {
        lastFrame = CGRectFromString([sizeSet_ objectForKey:[NSNumber numberWithInteger:index]]);
    }
    else if(index >=0)
    {
        if(index>0)
            lastFrame = [self getFrameForIndex:index-1];
        else if(index==0)
            lastFrame = CGRectMake(self.leftMargin, self.topMargin, 0, 0);
        
        CGSize tempSize = [self.dataSource commentListView:self sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        CGFloat y = MAX(lastFrame.origin.y+lastFrame.size.height+self.verticalSpace+arc4random()%30, [self getLeftOrTopForIndex:index]);
        CGRect frame = CGRectMake(self.leftMargin, y, tempSize.width, tempSize.height);
        [sizeSet_ setObject:NSStringFromCGRect(frame) forKey:[NSNumber numberWithInteger:index]];
        lastFrame = frame;
    }
    return lastFrame;
}
- (CGFloat)getLeftOrTopForIndex:(NSInteger)index
{
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    CGFloat duranceForWhen = [self.dataSource commentListView:self duranceForWhenForItemAtIndexPath:indexPath];
    CGFloat value = duranceForWhen * 150;
    NSLog(@"评论的时间：%.1f 评论的位置：%.1f",duranceForWhen,value);
    return value;
}
#pragma mark - scroll
-(NSInteger)get_startVisibleIndex
{
    CGFloat offset = self.scrollOffset;
    NSInteger index = NSNotFound;
    NSArray * indexList = [[sizeSet_ allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSNumber * cIndex in indexList) {
        CGRect frame = CGRectFromString([sizeSet_ objectForKey:cIndex]);
        if(frame.origin.y <= offset && frame.origin.y + frame.size.height > offset)
        {
            index = [cIndex integerValue];
            break;
        }
    }
    return index;
}
- (void)setScrollOffset:(CGFloat)scrollOffset updateLayout:(BOOL)updateLayout
{
    if (offsetTarget_ != scrollOffset)
    {
        //        isScrolling_ = NO; //stop scrolling
        offsetTarget_ = scrollOffset;
        
        if(scrollOffset <0)
        {
            UIEdgeInsets insets = self.contentInset;
            insets.top = 0 - scrollOffset;
            self.contentInset = insets;
            CGPoint contentOffset =  CGPointMake(self.contentOffset.x,offsetTarget_);
            self.contentOffset = contentOffset;
        }
        else
        {
            
            UIEdgeInsets insets = self.contentInset;
            //            UIEdgeInsetsMake(0 - offsetTarget_, 0, 0, 0);
            if(insets.top>0)
            {
                insets.top = 0;
                self.contentInset = insets;
            }
            CGPoint contentOffset =  CGPointMake(self.contentOffset.x,offsetTarget_);
            self.contentOffset = contentOffset;
        }
        if(updateLayout)
            [self updateLayout];
        
    }
}

- (CGFloat)scrollByOffsetInThread:(CGFloat)offset duration:(NSTimeInterval)duration
{
    if(isScrolling_) // 如果return 评论出现的位置需要重新计算
    {
//        NSLog(@" isScrolling");
//        return 0;
    }
    if ([NSThread isMainThread]) {
        [self scrollByOffset:offset duration:duration];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollByOffset:offset duration:duration];
        });
    }
    return duration;
}

- (CGFloat)scrollByOffset:(CGFloat)offset duration:(NSTimeInterval)duration
{
    if (duration > 0.0)
    {
        isScrolling_ = YES;
        // NSLog(@" duration scroll to ---> %0.1f",self.scrollOffset + offset);
        [UIView animateWithDuration:duration animations:^(void)
         {
             [self setScrollOffset:self.scrollOffset + offset updateLayout:NO];
         }completion:^(BOOL finished)
         {
             [self updateLayout];
             isScrolling_ = NO;
         }];
    }
    else
    {
        NSLog(@" scroll to %0.1f",self.scrollOffset + offset +self.frame.size.width);
        [self setScrollOffset:self.scrollOffset + offset updateLayout:YES];
        isScrolling_ = NO;
    }
    return duration;
}

#pragma mark View loading
- (void)updateScrollViewDimensions
{
    CGRect frame = CGRectFromString([sizeSet_ objectForKey:[NSNumber numberWithLong:(totalCount_-1)]]);
    
    if(self.contentSize.height < frame.origin.y + frame.size.height)
    {
        self.contentSize = CGSizeMake(self.frame.size.width, MAX(frame.origin.y + frame.size.height,self.frame.size.height + self.bottomMargin + self.topMargin) );
    }
}

- (NSInteger)numberOfVisibleItems:(NSInteger *)indexBegin end:(NSInteger *)indexEnd
{
    if(self.dataSource)
    {
        totalCount_ = [self.dataSource commentListView:self numberOfItemsInSection:0];
    }
    
    CGFloat offsetMin = self.contentOffset.y - self.frame.size.height/4;
    CGFloat offsetMax = self.frame.size.height*5/4 + offsetMin;
    //    UIEdgeInsets insets = self.contentInset;
    //
    //    offsetMax -= insets.top + insets.bottom;
    
    NSInteger index = 0;
    *indexBegin = -1;
    *indexEnd = -2;
    //上下各多保留至少一条数据
    //由于是按位置的正序来处理的，所以简化判断
    for (; index < totalCount_; index ++) {
        CGRect frame = [self getFrameForIndex:index];
        if(frame.origin.y +frame.size.height > offsetMin && *indexBegin <0)
        {
            *indexBegin = index;
        }
        else if(frame.origin.y > offsetMax +frame.size.height )
        {
            *indexEnd = index-1;
            break;
        }
        if(frame.origin.y > offsetMax)
        {
            lastRow_ = MAX(0,index -1);
        }
        else
        {
            lastRow_ = index;
        }
    }
    lastRow_ = *indexEnd;
    
    if(*indexEnd < 0) {
        *indexEnd = totalCount_ -1;
    }
    if (*indexBegin < 0) {
        *indexBegin = *indexEnd;
        lastRow_ = *indexEnd;
        return 0;
    }
    
    return *indexEnd - *indexBegin +1;
}
- (void)loadUnloadViews
{
    NSInteger indexBegin = 0;
    NSInteger indexEnd = 0;
    NSInteger numberOfVisibleItems = [self numberOfVisibleItems:&indexBegin end:&indexEnd];
    
    //    NSLog(@"index:%ld-->%ld,showcount:%ld",indexBegin,indexEnd,numberOfVisibleItems);
    NSMutableArray *visibleIndices = [[NSMutableArray alloc]initWithCapacity:numberOfVisibleItems];
    
    
    for (NSInteger i = indexBegin; i <= indexEnd; i++)
    {
        if (numberOfVisibleItems != 0)
        {
            [visibleIndices addObject:[NSNumber numberWithInteger:i]];
        }
    }
    
    //remove offscreen views
    for (NSNumber *number in [cells_ allKeys])
    {
        if (![visibleIndices containsObject:number])
        {
            UIView *view = [cells_ objectForKey:number];
            [self removeViewItem:view row:[number integerValue] animates:YES];
            [cells_ removeObjectForKey:number];
            NSLog(@"removeObjectForKey:%@",number);
        }
    }
    
    CGFloat offsetY = self.contentOffset.y;
    //    CGFloat offsetBottom = self.contentOffset.y + self.frame.size.height;
    //    CGFloat offsetYMax = self.contentOffset.y + self.frame.size.height;
    //add onscreen views
    for (NSNumber *number in visibleIndices)
    {
        UICommentItemView *view = [cells_ objectForKey:number];
        if (view == nil)
        {
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[number integerValue] inSection:0];
            view = [self.dataSource commentListView:self cellForItemAtIndexPath:indexPath];
            view.staySeconds = -1;
            if(view)
            {
                [cells_ setObject:view forKey:number];
                NSLog(@"AddObjectForKey:%@",number);
                [self addViewItem:view row:[number integerValue] animates:NO];
            }
            if(self.dataSource && [self.dataSource respondsToSelector:@selector(commentListView:didEndDisplayCell:)])
            {
                [self.dataSource commentListView:self didEndDisplayCell:indexPath];
            }
        }
        
        if(view)
        {
            if(self.scrollByUser)
            {
                if(view.frame.origin.y < offsetY +100 && view.alpha >0)
                {
                    CGFloat alpha =  MIN(1,((offsetY - view.frame.origin.y)> view.frame.size.height?
                                            0
                                            :
                                            (1- (offsetY + 100 - view.frame.origin.y)/(view.frame.size.height+100))));
                    
                    view.alpha = alpha;
                    view.hidden = NO;
                }
                else
                {
                    view.alpha = 1;
                    view.hidden = NO;
                }
                [self showViewItem:view row:[number integerValue] animates:YES];
            }
            else if([view needHide:self.playerDuration])
            {
                //                NSLog(@"%f",self.playerDuration);
                //                NSLog(@"row:%d alpha:%0.1f  player:%f du:%0.1f ",view.row,view.alpha,self.playerDuration,view.Data.DuranceForWhen);
                //                view.alpha = 0;
                //                view.hidden = YES;
                [self hideViewItem:view row:[number integerValue] animates:YES];
            }
            else
            {
                if(view.frame.origin.y < offsetY +100)
                {
                    if(view.alpha>0)
                    {
                        CGFloat alpha =  MIN(1,((offsetY - view.frame.origin.y)> view.frame.size.height?
                                                0
                                                :
                                                (1- (offsetY + 100 - view.frame.origin.y)/(view.frame.size.height+100))));
                        
                        view.alpha = alpha;
                        view.hidden = NO;
                    }
                    [self showViewItem:view row:[number integerValue] animates:YES];
                }
                else if(view.alpha ==0 && view.staySeconds == -1)
                {
                    [self showViewItem:view row:view.row animates:YES];
                }
                //                 NSLog(@"view row:%d alpha:%0.1f stayseconds:%0.1f --",view.row,view.alpha,view.staySeconds);
            }
            //                if(self.scrollByUser)
            //                {
            //                    view.alpha = 1;
            //                }
            //                else if([view needHide:self.playerDuration])
            //                {
            //                    view.alpha = 0;
            //                }
            //
            //            }
            
        }
        
        //    NSLog(@" row:%d frame:%@ alpha:%0.1f offset:%0.1f",[number integerValue],NSStringFromCGRect(view.frame),view.alpha,self.scrollOffset +self.frame.size.height);
    }
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if ([view isEqual:self])
    {
        for (UIView *subview in self.subviews)
        {
            CGPoint offset = CGPointMake(point.x - self.frame.origin.x + self.contentOffset.x - subview.frame.origin.x,
                                         point.y - self.frame.origin.y + self.contentOffset.y - subview.frame.origin.y);
            
            if ((view = [subview hitTest:offset withEvent:event]))
            {
                return view;
            }
        }
        return self;
    }
    return view;
}

- (CGFloat)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    CGFloat duration = 0;
    
    CGRect targetFrame = [self getFrameForIndex:indexPath.row];
    CGFloat offset = self.scrollOffset;
    CGFloat offsetSpace  =  0;
    
    //    NSLog(@"---->  scroll to index %d,",indexPath.row);
    lastRow_ = indexPath.row;
    //    if(indexPath.row>=19)
    //    {
    //        NSLog(@"observer item alpha");
    //    }
    
    if(scrollPosition == UICollectionViewScrollPositionTop)
        offsetSpace = targetFrame.origin.y + targetFrame.size.height ;
    else
        offsetSpace = targetFrame.origin.y + targetFrame.size.height - self.frame.size.height;
    
    offsetSpace -= offset;
    offsetSpace = roundf((offsetSpace+0.25)*2)/2.0f;
    
    if(animated)
    {
        duration = [self scrollByOffset:offsetSpace duration:0.35];
    }
    else
    {
        duration = [self scrollByOffset:offsetSpace duration:0];
    }
    return duration;
}
@end
