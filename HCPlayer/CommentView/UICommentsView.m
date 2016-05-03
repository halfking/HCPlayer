//
//  UICommentsView.m
//  maiba
//
//  Created by HUANGXUTAO on 15/8/24.
//  Copyright (c) 2015年 seenvoice.com. All rights reserved.
//

#import "UICommentsView.h"
#import "UICommentItemView.h"
#import "CommentAnimateItem.h"
#import <HCBaseSystem/comments_wt.h>
@implementation UICommentsView
@synthesize scrollOffset = offsetTarget_;

//@synthesize visibleCells = visibleCells_;

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
    cells_ = [NSMutableDictionary new];
    cellsPool_ = [NSMutableSet new];
    //    visibleCells_ = [NSMutableArray new];
    sizeSet_ = [NSMutableDictionary new];
    totalCount_ = 0;
    lastRow_ = 0;
    animatesDoing_ = NO;
}
- (void)reset
{
    [self clearAnimateItems];
    [cells_ removeAllObjects];
    [cellsPool_ removeAllObjects];
    PP_RELEASE(cells_);
    PP_RELEASE(cellsPool_);
    
    [self clearCache];
    [self setDefault];
    
    offsetTarget_ = 0;
    offsetBegin_ = 0;
    offsetEnd_ = 0;
    scrollDuration_ = 0;
    isScrolling_ = NO;
    if(scrollTimer_)
    {
        [scrollTimer_ invalidate];
        scrollTimer_ = nil;
    }
    for (UIView * view in self.subviews) {
        [view removeFromSuperview];
    }
    totalCount_ = 0;
}
- (void)dealloc
{
    [self clearAnimateItems];
    PP_RELEASE(cells_);
    PP_RELEASE(cellsPool_);
    PP_RELEASE(sizeSet_);
    if(scrollTimer_)
    {
        [scrollTimer_ invalidate];
        scrollTimer_ = nil;
    }
    //    PP_RELEASE(visibleCells_);
    
    PP_SUPERDEALLOC;
}
- (void)readyToRelease
{
    [self reset];
}
- (void)clearCache
{
    [sizeSet_ removeAllObjects];
}
- (void)removeCache:(NSInteger)index
{
    BOOL changed = NO;
    @synchronized(self)
    {
        NSArray * indexList = [[sizeSet_ allKeys] sortedArrayUsingSelector:@selector(compare:)];
        
        for (NSNumber * cIndex in indexList) {
            if([cIndex integerValue] >= index)
            {
                [sizeSet_ removeObjectForKey:cIndex];
            }
        }
        for (NSNumber * cIndex in cells_.allKeys) {
            if([cIndex integerValue]>=index)
            {
                UIView * view = [cells_ objectForKey:cIndex];
                [view removeFromSuperview];
                [cells_ removeObjectForKey:cIndex];
                changed = YES;
                
                NSLog(@"remove item:%@ index:%ld",((UICommentItemView*)view).Data.Content,(long)[cIndex integerValue]);
            }
        }
        for (NSInteger cIndex = animatesArray_.count-1;cIndex >=0;cIndex --){
            CommentAnimateItem * item = [animatesArray_ objectAtIndex:cIndex];
            if(item.row >= index)
            {
                [animatesArray_ removeObjectAtIndex:cIndex];
            }
        }
    }
    if(changed)
    {
        [self updateLayout];
    }
}
#pragma mark -
#pragma mark View management

- (NSArray *)indexesForVisibleItems
{
    return [[cells_ allKeys] sortedArrayUsingSelector:@selector(compare:)];
}
- (NSArray *)visibleItemViewsWithoutZeroAlpha
{
    return nil;
}
- (NSArray *)visibleItemViews
{
    NSArray *indexes = [self indexesForVisibleItems];
    return [cells_ objectsForKeys:indexes notFoundMarker:[NSNull null]];
}

- (UIView *)itemViewAtIndex:(NSInteger)index
{
    return [cells_ objectForKey:[NSNumber numberWithInteger:index]];
}
- (NSInteger)indexOfItemView:(UIView *)view
{
    NSInteger index = [[cells_ allValues] indexOfObject:view];
    if (index != NSNotFound)
    {
        return [[[cells_ allKeys] objectAtIndex:index] integerValue];
    }
    return NSNotFound;
}

- (NSInteger)indexOfItemViewOrSubview:(UIView *)view
{
    NSInteger index = [self indexOfItemView:view];
    if (index == NSNotFound && view != nil && view != self)
    {
        return [self indexOfItemViewOrSubview:view.superview];
    }
    return index;
}

- (void)setItemView:(UIView *)view forIndex:(NSInteger)index
{
    [(NSMutableDictionary *)cells_ setObject:view forKey:[NSNumber numberWithInteger:index]];
}

- (void)setFrameForView:(UIView *)view atIndex:(NSInteger)index
{
    //    CGRect frame = [self getFrameForIndex:index];
    //    CGRect orgFrame = view.frame;
    //    if(!CGRectEqualToRect(frame, orgFrame))
    //    {
    //        view.frame = frame;
    //    }
}
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
        CGRect frame = CGRectMake(self.leftMargin, lastFrame.origin.y+lastFrame.size.height+self.verticalSpace, tempSize.width, tempSize.height);
        [sizeSet_ setObject:NSStringFromCGRect(frame) forKey:[NSNumber numberWithInteger:index]];
        lastFrame = frame;
    }
    return lastFrame;
}
#pragma mark - scroll
-(void)setInitItemIndex:(NSInteger)initItemIndex
{
    _initItemIndex = initItemIndex;
    
    CGRect frame = [self getFrameForIndex:initItemIndex];
    offsetTarget_ = frame.origin.y;
}
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
        // NSLog(@" scroll to %0.1f",self.scrollOffset + offset +self.frame.size.width);
        [self setScrollOffset:self.scrollOffset + offset updateLayout:YES];
        isScrolling_ = NO;
    }
    return duration;
}

- (void)startAnimation
{
    NSLog(@"begin timer");
    if (!scrollTimer_)
    {
        scrollTimer_ = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0
                                                        target:self
                                                      selector:@selector(step)
                                                      userInfo:nil
                                                       repeats:YES];
    }
}

- (void)stopAnimation
{
    NSLog(@"release timer");
    [scrollTimer_ invalidate];
    scrollTimer_ = nil;
}
- (void)step
{
    if (isScrolling_)
    {
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSinceReferenceDate];
        NSTimeInterval time = fminf(1.0f, (currentTime - scrollTimeBegin_) / scrollDuration_);
        CGFloat delta = [self easeInOut:time];
        
        [UIView setAnimationsEnabled:NO];
        //        self.scrollOffset += (offsetEnd_ - offsetBegin_) * delta;
        CGFloat offsetDelta = MIN(offsetEnd_, self.scrollOffset + (offsetEnd_ - offsetBegin_) * delta );
        [self setScrollOffset:offsetDelta updateLayout:NO];
        NSLog(@"current offset:%0.1f, from :%0.1f to %0.1f",self.scrollOffset,offsetBegin_,offsetEnd_);
        [UIView setAnimationsEnabled:YES];
        if (time == 1.0f || offsetDelta == offsetEnd_)
        {
            NSLog(@"scroll item end 1");
            isScrolling_ = NO;
            [self stopAnimation];
            
        }
    }
    else
    {
        NSLog(@"scroll item end");
        [self stopAnimation];
    }
}
//- (void)setContentOffsetWithoutEvent:(CGPoint)contentOffset
//{
//    [UIView setAnimationsEnabled:NO];
//    //    _suppressScrollEvent = YES;
//
//    //
//    //        if(self.contentSize.height < contentOffset.y + _itemSize.height * minCount)
//    //        {
//    //            CGSize size = _scrollView.contentSize;
//    //            size.height = contentOffset.y + _itemSize.height * minCount;
//    //            _scrollView.contentSize = size;
//    //        }
//    //
//    self.contentOffset = contentOffset;
//    //    _suppressScrollEvent = NO;
//    [UIView setAnimationsEnabled:YES];
//}
//将偏移量对准为几个标准的对像高度，不要出现只显示半个对像的问题
- (CGFloat)clampedOffset:(CGFloat)offset
{
    return offset;
    //    int count = _vertical?_numberOfItems/_itemsPerRow:_numberOfItems/_itemsPerColumn;
    //    if (_wrapEnabled)
    //    {
    //        return count? (offset - floorf(offset / (CGFloat)count) * count): 0.0f;
    //        //        return _numberOfItems? (offset - floorf(offset / (CGFloat)_numberOfItems) * _numberOfItems): 0.0f;
    //    }
    //    else
    //    {
    //        return fminf(fmaxf(0.0f, offset), (CGFloat)count - 1.0f);
    //        //        return fminf(fmaxf(0.0f, offset), (CGFloat)_numberOfItems - 1.0f);
    //    }
}
- (CGFloat)easeInOut:(CGFloat)time
{
    return (time < 0.5f)? 0.5f * powf(time * 2.0f, 3.0f): 0.5f * powf(time * 2.0f - 2.0f, 3.0f) + 1.0f;
}

#pragma mark - layout

- (void)layOutItemViews
{
    for (UIView *view in self.visibleItemViews)
    {
        NSInteger index = [self indexOfItemView:view];
        [self setFrameForView:view atIndex:index];
    }
}

- (void)updateLayout
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self updateItemSizeAndCount];
        //    [self updateScrollViewDimensions];
        //    [self updateScrollOffset];
        
        //    [UIView setAnimationsEnabled:NO]; // 去掉有动画
        [self loadUnloadViews];
        [UIView setAnimationsEnabled:YES];
        [self layOutItemViews];
        
    });
}

- (void)layoutSubviews
{
    [self updateLayout];
}
#pragma mark View loading

//- (UIView *)loadViewAtIndex:(NSIndexPath *)indexPath
//{
//    UIView * view = [self.dataSource commentListView:self cellForItemAtIndexPath:indexPath];
//    if(view)
//    {
//        [self addSubview:view];
//    }
////    DLog(@"view offset :%f  view:%f",_scrollView.contentOffset.x,view.frame.origin.x);
//    return view;
//}
- (void)updateScrollViewDimensions
{
    CGRect frame = [self getFrameForIndex:totalCount_-1];
    
    if(self.contentSize.height < frame.origin.y + frame.size.height)
    {
        self.contentSize = CGSizeMake(self.frame.size.width, MAX(frame.origin.y + frame.size.height,self.frame.size.height + self.bottomMargin + self.topMargin) );
    }
    
    //    CGRect frame = self.bounds;
    //    CGSize contentSize = frame.size;
    //    int totalPage = _numberOfItems /_itemsPerPage + (_numberOfItems%_itemsPerPage>0?1:0);
    //
    //
    //    if (!CGSizeEqualToSize(_scrollView.contentSize, contentSize))
    //    {
    //        //        CGPoint offset = _scrollView.contentOffset;
    //        _scrollView.contentSize = contentSize;
    //        //        if(offset.x <=contentSize.width && offset.y <= contentSize.height)
    //        //            _scrollView.contentOffset = offset;
    //    }
    //    if(_initItemIndex>0)
    //    {
    //        int offsetIndex = _vertical?_initItemIndex/_itemsPerRow:_initItemIndex/_itemsPerColumn;
    //
    //        CGPoint contentOffset = _vertical?
    //        CGPointMake(0.0f, [self clampedOffset:offsetIndex] * _itemSize.height):
    //        CGPointMake([self clampedOffset:offsetIndex] * _itemSize.width, 0.0f);
    //        [self setContentOffsetWithoutEvent:contentOffset];
    //
    //        _currentOffsetIndex = _initItemIndex;
    //
    //        //已经处理过了，则不需要了
    //        _initItemIndex = 0;
    //    }
}

- (void)updateItemSizeAndCount
{
    NSInteger totalCount = [self.dataSource commentListView:self numberOfItemsInSection:0];
    if (totalCount_ != totalCount)
    {
        totalCount_ = totalCount;
    }
    [self updateScrollViewDimensions];
}
//- (void)makeItemsToRect:(NSMutableSet*)items
//{
//    int minColumn = 999999;
//    int maxColumn = 0;
//
//    for (NSNumber * number in items) {
//        int index =  [number integerValue];
//        int page = index / _itemsPerPage;
//        //        int row = index %_itemsPerPage / _itemsPerRow;
//        int column = index % _itemsPerPage % _itemsPerRow;
//        column += page * _itemsPerRow;
//        if(column<minColumn)
//        {
//            minColumn = column;
//        }
//        if(column> maxColumn)
//        {
//            maxColumn = column;
//        }
//    }
//    NSMutableArray  * arrayToAdd  =[[ NSMutableArray alloc]init];
//    //    NSLog(@"maxcolumn:%d,minColumn:%d",maxColumn,minColumn);
//    for(int i = 0;i<_itemsPerColumn;i++)
//    {
//        [arrayToAdd addObject:[NSNumber numberWithInt:minColumn * _itemsPerColumn + i]];
//        for(int j = 0;j<_itemsPerRow && j+minColumn < maxColumn-1;j++)
//        {
//            [arrayToAdd addObject:[NSNumber numberWithInt:(minColumn +j) * _itemsPerColumn + i]];
//        }
//        if(maxColumn * _itemsPerColumn + i<_numberOfItems)
//            [arrayToAdd addObject:[NSNumber numberWithInt:maxColumn * _itemsPerColumn + i]];
//    }
//    for(NSNumber * number in arrayToAdd)
//    {
//        BOOL isFind = NO;
//        for(NSNumber * n2 in items)
//        {
//            if([n2 integerValue]==[number integerValue])
//            {
//                isFind = YES;
//                break;
//            }
//        }
//        if(!isFind)
//        {
//            [items addObject:number];
//        }
//    }
//    [arrayToAdd release];
//    //    [arrayToRemove release];
//}
- (NSInteger)numberOfVisibleItems:(NSInteger *)indexBegin end:(NSInteger *)indexEnd
{
    CGFloat offsetMin = self.contentOffset.y;
    CGFloat offsetMax = self.frame.size.height + offsetMin;
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
    
    if(*indexEnd <0 ) *indexEnd = totalCount_ -1;
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
        [visibleIndices addObject:[NSNumber numberWithInteger:i]];
    }
    
    //remove offscreen views
    for (NSNumber *number in [cells_ allKeys])
    {
        if (![visibleIndices containsObject:number])
        {
            UIView *view = [cells_ objectForKey:number];
            [self removeViewItem:view row:[number integerValue] animates:YES];
            [cells_ removeObjectForKey:number];
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

//- (void)reloadItemAtIndex:(NSInteger)index
//{
//    @autoreleasepool {
//
//        //if view is visible
//        if ([self itemViewAtIndex:index])
//        {
//            //reload view
//            [self loadViewAtIndex:index];
//        }
//    }
//}

- (void)reloadData
{
    isScrolling_ = NO;
    [self stopAnimation];
    [self clearAnimateItems];
    
    [self setNeedsLayout];
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

#pragma mark - events

- (void)showViewItem:(UIView *)view row:(NSInteger)row animates:(BOOL)animates
{
    if(view.superview && view.hidden==NO && view.alpha >0)
        return;
    
    if(animates)
    {
        //        CommentAnimateItem * item = [CommentAnimateItem new];
        //        item.row = row;
        //        item.duration = 0;
        //        item.viewObject = view;
        //        item.animateType = CommentAdd;
        //        [self addAnimateItem:item];
        
        CommentAnimateItem * item = [CommentAnimateItem new];
        item.row = row;
        item.duration = 0.2;
        item.viewObject = view;
        item.animateType = CommentShow;
        [self addAnimateItem:item];
    }
    else
    {
        CommentAnimateItem * item = [CommentAnimateItem new];
        item.row = row;
        item.duration = 0;
        item.viewObject = view;
        item.animateType = CommentShow;
        [self addAnimateItem:item];
    }
}
- (void)hideViewItem:(UIView *)view row:(NSInteger)row animates:(BOOL)animates
{
    
    if(!view.superview || view.hidden == YES || view.alpha==0) return;
    if(!animates)
    {
        CommentAnimateItem * item = [CommentAnimateItem new];
        item.row = row;
        item.duration = 0;
        item.viewObject = view;
        item.animateType = CommentHide;
        [self addAnimateItem:item];
    }
    else
    {
        
        CommentAnimateItem * item = [CommentAnimateItem new];
        item.row = row;
        item.duration = 0.25;
        item.viewObject = view;
        item.animateType = CommentHide;
        [self addAnimateItem:item];
    }
    
}
- (void)addViewItem:(UIView *)view row:(NSInteger)row animates:(BOOL)animates
{
    CommentAnimateItem * item = [CommentAnimateItem new];
    item.row = row;
    item.duration = animates?0.25:0;
    item.viewObject = view;
    item.animateType = CommentAdd;
    [self addAnimateItem:item];
    //
    //    if(view.superview) return;
    //    [self addSubview:view];
}
- (void)removeViewItem:(UIView *)view row:(NSInteger)row animates:(BOOL)animates
{
    NSInteger index = [self existViewInAnimates:view];
    if(index == NSNotFound)
    {
        [self queueItemView:view];
        [view removeFromSuperview];
    }
    else
    {
        CommentAnimateItem * item = [CommentAnimateItem new];
        item.row = row;
        item.duration = 0;
        item.viewObject = view;
        item.animateType = CommentRemove;
        [self addAnimateItem:item];
    }
}
- (void)queueItemView:(UIView *)view
{
    if (view)
    {
        [cellsPool_ addObject:view];
        if([view respondsToSelector:@selector(prepareForReuse)])
        {
            [view performSelector:@selector(prepareForReuse)];
        }
    }
}
- (UICommentItemView *)dequeueReusableCellWithReuseIdentifier:(NSString*) cellIdentifier forIndexPath:(NSIndexPath *)indexPath
{
    UICommentItemView *view = PP_RETAIN([cellsPool_ anyObject]);
    if (view)
    {
        [cellsPool_ removeObject:view];
        [view prepareForReuse];
        
        CGRect rect = [self getFrameForIndex:indexPath.row];
        view.frame = rect;
        
        //        NSLog(@"resuse cell:%@ alpha:%0.1f hidden:%d",NSStringFromCGRect(view.frame),view.alpha,view.hidden);
    }
    else
    {
        CGRect rect = [self getFrameForIndex:indexPath.row];
        view = [[UICommentItemView alloc]initWithFrame:rect];
    }
    return PP_AUTORELEASE(view);
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
    
    //    if(targetFrame.origin.y > self.scrollOffset + offsetSpace + self.frame.size.height)
    //    {
    //        NSLog(@"*****-----error-----*****");
    //    }
    //NSLog(@"orgoffset:%0.1f r:%0.1f  changed:%0.1f target:%0.1f view:%@",self.contentOffset.y,self.scrollOffset,
    //      offsetSpace,offsetSpace + self.scrollOffset+self.frame.size.height,NSStringFromCGRect(targetFrame));
    if(animated)
    {
        duration = [self scrollByOffset:offsetSpace duration:0.35];
    }
    else
    {
        duration = [self scrollByOffset:offsetSpace duration:0];
    }
    //check show
    //    UIView * view = [cells_ objectForKey:[NSNumber numberWithInteger:indexPath.row]];
    //    if(view)
    //    {
    //        NSLog(@"viewItem:%@,alpha:%0.1f",NSStringFromCGRect(view.frame),view.alpha);
    //    }
    //        NSLog(@"---->row %d,offset:%0.1f viewy:%0.1f",indexPath.row,self.contentOffset.y + self.frame.size.height,targetFrame.origin.y);
    return duration;
}
#pragma mark - animates 编写一个动画序列，用于执行不同的操作，让异步操作顺序执行
- (void)addAnimateItem:(CommentAnimateItem *)item
{
    if(!item) return;
    //    item.duration = 0;
    //    dispatch_async(dispatch_get_main_queue(), ^{
    if(!animatesArray_)
    {
        animatesArray_ = [NSMutableArray new];
    }

    if([NSThread isMainThread])
    {
        [self doAnimatesItem:item];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self doAnimatesItem:item];
        });
    }
    //    });
    return;
    //        if(self.scrollByUser)
    //        {
    //            [self clearAnimateItems];
    //            item.duration = 0;
    //            [self doAnimatesItem:item];
    //            return;
    //        }
    //
    //        @synchronized(self)
    //        {
    //            if(!animatesArray_)
    //            {
    //                animatesArray_ = [NSMutableArray new];
    //            }
    //
    //            //连续滚动合并掉
    //            if (item.animateType == CommentScroll) {
    //                CommentAnimateItem * lastItem = nil;
    //                NSInteger index = animatesArray_.count -1;
    //                for (;index>=0;index--) {
    //                    lastItem = [animatesArray_ objectAtIndex:index];
    //                    if(lastItem.animateType == CommentScroll)
    //                    {
    //                        break;
    //                    }
    //                    else
    //                    {
    //                        lastItem = nil;
    //                    }
    //                }
    //                if(index >0 && lastItem && lastItem.animateType == CommentScroll)
    //                {
    //                    [animatesArray_ removeObject:lastItem];
    //                }
    //            }
    //            [animatesArray_ addObject:item];
    //
    //            #ifndef __OPTIMIZE__
    //                    NSLog(@"-----------------------");
    //                    for (CommentAnimateItem * cItem in animatesArray_) {
    //
    //                        NSString * animteStr = nil;
    //                        switch (cItem.animateType) {
    //                            case CommentAdd:
    //                                animteStr = @"add";
    //                                break;
    //                            case CommentHide:
    //                                animteStr = @"hide";
    //                                break;
    //                            case CommentRemove:
    //                                animteStr = @"remove";
    //                                break;
    //                            case CommentScroll:
    //                                animteStr = @"scroll";
    //                                break;
    //                            case CommentShow:
    //                                animteStr = @"show";
    //                                break;
    //                            default:
    //                                animteStr = @"unkown";
    //                                break;
    //                        }
    //                        NSLog(@"add animates: row :%d event:%@ duration:%0.2f offset:%0.1f",cItem.row,animteStr,cItem.duration,self.scrollOffset);
    //                    }
    //                    NSLog(@"-----------------------");
    //            #endif
    //        }
}
- (void)clearAnimateItems
{
    @synchronized(self)
    {
        [animatesArray_ removeAllObjects];
        if(animateTimer_)
        {
            [animateTimer_ invalidate];
            animateTimer_ = nil;
        }
        animatesDoing_ = NO;
    }
}
- (NSInteger)existViewInAnimates:(UIView *)view
{
    NSInteger index = NSNotFound;
    if(animatesArray_)
    {
        @synchronized(self)
        {
            for (index = animatesArray_.count -1; index>=0; index--) {
                CommentAnimateItem * item = [animatesArray_ objectAtIndex:index];
                if(item.viewObject == view)
                {
                    break;
                }
            }
            if(index <0)
            {
                index = NSNotFound;
            }
        }
    }
    return index;
}
- (void)removeAnimateItem:(CommentAnimateItem *)item
{
    if(animatesArray_)
    {
        @synchronized(self)
        {
            int index = 0;
            for (CommentAnimateItem * cItem in animatesArray_) {
                if(cItem == item)
                {
                    break;
                }
                index ++;
            }
            if(index < animatesArray_.count && (index >0 ||(!animateTimer_ && index==0)))
            {
                [animatesArray_ removeObject:item];
            }
        }
    }
}

- (void)doAnimates:(NSTimer *)timer
{
    if(!animatesArray_ || animatesArray_.count==0)
    {
        [animateTimer_ invalidate];
        animateTimer_ = nil;
        animatesDoing_ = NO;
        return ;
    }
    
    if (animatesDoing_) {
        return;
    }
    
    animatesDoing_ = YES;
    
    CGFloat duration = 0;
    while (animatesArray_ && animatesArray_.count>0) {
        CommentAnimateItem * item = nil;
        @synchronized(self){
            if(animatesArray_.count>0)
            {
                item = [animatesArray_ objectAtIndex:0];
                [animatesArray_ removeObjectAtIndex:0];
            }
        }
        if(item)
        {
            duration = [self doAnimatesItem:item];
            if(duration >0)
            {
                [NSThread sleepForTimeInterval:duration];
            }
        }
        //检查队列，看是否需要加速
        if(animatesArray_.count>10)
        {
            @synchronized(self)
            {
                for (CommentAnimateItem * item in animatesArray_) {
                    item.duration /= (animatesArray_.count / 10 +1);
                    if(item.duration<0.05)
                    {
                        item.duration = 0;
                    }
                }
            }
        }
    }
    animatesDoing_ = NO;
}


- (CGFloat)doAnimatesItem:(CommentAnimateItem *)item
{
    CGFloat endDuration = 0;//item.duration;
#ifndef __OPTIMIZE__
    NSString * animteStr = nil;
    switch (item.animateType) {
        case CommentAdd:
            animteStr = @"add";
            break;
        case CommentHide:
            animteStr = @"hide";
            break;
        case CommentRemove:
            animteStr = @"remove";
            break;
        case CommentScroll:
            animteStr = @"scroll";
            break;
        case CommentShow:
            animteStr = @"show";
            break;
        case CommentSlideIn:
            animteStr = @"slidein";
            break;
        default:
            animteStr = @"unkown";
            break;
    }
        // NSLog(@"do animates: row :%d event:%@ duration:%0.2f offset:%0.1f,alpha:%0.1f",item.row,animteStr,item.duration,self.scrollOffset,item.viewObject.alpha);
#endif
    switch (item.animateType) {
        case CommentScroll:
            item.duration = 0.15;
            //            int i = 0;
            //            while (isScrolling_ && i < 10)
            //            {
            //                [NSThread sleepForTimeInterval:0.05];
            //                i ++;
            //            }
            //            if(i>=10)
            //            {
            //                NSLog(@"other");
            //            }
            
            
            //            endDuration = [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item.row inSection:0]
            //                                       atScrollPosition:UICollectionViewScrollPositionBottom
            //                                               animated:item.duration >0];
            if(endDuration > 0)
            {
                endDuration = 0.15; //滚动比实际的要慢，这样能让下面的同步显示
            }
            
            //            endDuration = 0;
            break;
        case CommentAdd:
            endDuration  = [self animatesDoViewAdd:item];
            break;
        case CommentHide:
            endDuration  = [self animatesDoViewHide:item];
            break;
        case CommentRemove:
            
            endDuration  = [self animatesDoViewRemove:item];
            break;
        case CommentSlideIn:
            endDuration = [self animatesDoViewSlideIn:item];
            break;
        case CommentShow:
        default:
            endDuration  =[self animatesDoViewShow:item];
            break;
    }
    return endDuration+0.01;
    //    if(animateTimer_)
    //    {
    //        [animateTimer_ invalidate];
    //        animateTimer_ = nil;
    //        animateTimer_ = [NSTimer scheduledTimerWithTimeInterval:endDuration+0.01 target:self selector:@selector(doAnimates:) userInfo:nil repeats:NO];
    //    }
}
- (CGFloat)animatesDoViewRemove:(CommentAnimateItem *)item
{
    if(item.viewObject.alpha >0 && item.viewObject.superview)
    {
        [UIView animateWithDuration:item.duration animations:^(void)
         {
             item.viewObject.alpha  = 0;
         }
                         completion:^(BOOL finished)
         {
             [item.viewObject removeFromSuperview];
             [self queueItemView:item.viewObject];
         }];
        return item.duration;
    }
    else{
        [item.viewObject removeFromSuperview];
        [self queueItemView:item.viewObject];
    }
    return 0;
}
- (CGFloat)animatesDoViewHide:(CommentAnimateItem *)item
{
    if(item.duration >0)
    {
        [UIView animateWithDuration:item.duration animations:^(void)
         {
             item.viewObject.alpha  = 0;
         }
                         completion:^(BOOL finished)
         {
             item.viewObject.hidden = YES;
         }];
        return item.duration;
    }
    else
    {
        item.viewObject.alpha = 0;
        item.viewObject.hidden = YES;
        return 0;
    }
}
- (CGFloat)animatesDoViewAdd:(CommentAnimateItem *) item
{
    item.viewObject.alpha = 0;
    if(!item.viewObject.superview)
        [self addSubview:item.viewObject];
    return 0;
}
- (CGFloat)animatesDoViewSlideIn:(CommentAnimateItem *) item
{
    item.viewObject.alpha = 1;
    //    item.viewObject.backgroundColor = [UIColor redColor];
    CGRect frame = item.viewObject.frame;
    CGFloat left = self.contentOffset.x;
    item.viewObject.frame = CGRectMake(left + self.frame.size.width, frame.origin.y, frame.size.width, frame.size.height);
    
    if(!item.viewObject.superview)
        [self addSubview:item.viewObject];
    
    //不能一加入就消失，因此至少顶头位置
    
    if(frame.origin.x < left + [DeviceConfig config].Height/2)
    {
        frame.origin.x = left + [DeviceConfig config].Height/2;
    }
    
    if (item.duration > 0.0)
    {
        [UIView animateWithDuration:item.duration animations:^(void)
         {
             item.viewObject.frame = frame;
         }];
    }
    else
    {
        item.viewObject.frame = frame;
    }
    
    return item.duration;
}
- (CGFloat)animatesDoViewShow:(CommentAnimateItem *)item
{
    if(item.duration >0)
    {
        if(!item.viewObject.superview)
            [self addSubview:item.viewObject];
        item.viewObject.hidden =NO;
        if(item.viewObject.alpha <1)
        {
            [UIView animateWithDuration:item.duration animations:^(void)
             {
                 item.viewObject.alpha  = 1;
             }];
        }
        return item.duration;
    }
    else
    {
        item.viewObject.alpha = 1;
        item.viewObject.hidden = NO;
        if(!item.viewObject.superview)
            [self addSubview:item.viewObject];
        return 0;
    }
    
}

@end
