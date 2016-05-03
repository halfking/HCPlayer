//
//  UICommentsPopView.m
//  maiba
//
//  Created by HUANGXUTAO on 15/8/24.
//  Copyright (c) 2015年 seenvoice.com. All rights reserved.
//

#import "UICommentsPopView.h"

#import "UICommentItemView.h"

@implementation UICommentsPopView
@synthesize numberOfLines;

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        numberOfLines = -1;
        [self setDefault];
    }
    return self;
}
- (void)setDefault
{
    [super setDefault];
    lineRights = [NSMutableArray new];
    lineTops = [NSMutableArray new];
    if (numberOfLines < 0) {
        numberOfLines = 6;
    }
    //    numberOfLines = 6;
    
    [self setNumberOfLines:numberOfLines];
}
- (void)setNumberOfLines:(int)pnumberOfLines
{
    if(pnumberOfLines <=0) return;
    numberOfLines = pnumberOfLines;
    
    if(lineRights.count < pnumberOfLines)
    {
        for (int i = (int)lineRights.count;i<pnumberOfLines;i++) {
            if (i % 2 == 0) {
                [lineRights addObject:[NSNumber numberWithFloat:0]];
            }
            else
            {
                [lineRights addObject:[NSNumber numberWithFloat:20 * i - (arc4random()%20)]];
            }
        }
    }
    
    [lineTops removeAllObjects];
//    NSLog(@"topMargin %f",self.topMargin);
    CGFloat rowHeight = roundf((self.frame.size.height - self.topMargin - self.bottomMargin)/pnumberOfLines * 10)/10;
    CGFloat top = self.topMargin;
    
    for (int i = 0; i < pnumberOfLines; i ++) {
        [lineTops addObject:[NSNumber numberWithFloat:top]];
        top += rowHeight;
    }
}
- (void)reset
{
    [super reset];
    [lineRights removeAllObjects];
    [lineTops removeAllObjects];
    
    [self setNumberOfLines:numberOfLines];
}
- (void)dealloc
{
    PP_RELEASE(lineRights);
    PP_RELEASE(lineTops);
    
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
        NSLog(@"获取第几个评论的frame ——————> %u",index);
        
        //简化处理，不存在于缓存中的均认为是最后一个添加进来的对像
        NSInteger lineIndex = [self getItemLine:index];
        CGPoint leftTop = CGPointMake([[lineRights objectAtIndex:lineIndex]floatValue], [[lineTops objectAtIndex:lineIndex]floatValue]);
        if(leftTop.x > self.leftMargin) //不是第一个，则需要加上间隔
        {
            leftTop.x += (self.itemSpace + arc4random()%100);
        }
        
        leftTop.x = MAX(leftTop.x,([self getLeftOrTopAtIndex:index]));
        
        CGSize tempSize = [self.dataSource commentListView:self sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        
        CGRect frame = CGRectMake(leftTop.x, leftTop.y, tempSize.width, tempSize.height);
        [sizeSet_ setObject:NSStringFromCGRect(frame) forKey:[NSNumber numberWithInteger:index]];
        
        CGFloat left = self.contentOffset.x;
        //不能一加入就消失，因此至少屏幕居中的位置
        if(frame.origin.x < left + [DeviceConfig config].Height/2)
        {
            frame.origin.x = left + [DeviceConfig config].Height/2;
        }
        
        lastFrame = frame;
        
        CGFloat right = [[lineRights objectAtIndex:lineIndex]floatValue];
        if(right < frame.origin.x + frame.size.width)
        {
            right = frame.origin.x + frame.size.width;
            
            [lineRights replaceObjectAtIndex:lineIndex withObject:[NSNumber numberWithFloat:right]];
        }
        
        //
        //        if(index>0)
        //        {
        //            lastFrame = [self getFrameForIndex:index-1];
        //        }
        //        else if(index==0)
        //        {
        //            lastFrame = CGRectMake(self.leftMargin, self.topMargin, 0, 0);
        //        }
        //
        //        CGSize tempSize = [self.dataSource commentListView:self sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        //
        //        CGRect frame = CGRectMake(self.topMargin, lastFrame.origin.y+lastFrame.size.height+self.verticalSpace, tempSize.width, tempSize.height);
        //        [sizeSet_ setObject:NSStringFromCGRect(frame) forKey:[NSNumber numberWithInteger:index]];
        //        lastFrame = frame;
    }
    else
    {
        
    }
    
    //    CGFloat left = self.contentOffset.x;
    //    //不能一加入就消失，因此至少顶头位置
    //    if(lastFrame.origin.x < left + [DeviceConfig config].Height/2)
    //    {
    //        lastFrame.origin.x = left + [DeviceConfig config].Height/2;
    //    }
    
    return lastFrame;
}

- (CGFloat)getLeftOrTopAtIndex:(NSInteger)index
{
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    CGFloat duranceForWhen = [self.dataSource commentListView:self duranceForWhenForItemAtIndexPath:indexPath];
    CGFloat value = duranceForWhen * 150 - self.frame.size.width/2;
    NSLog(@"评论的时间：%.1f 评论的位置：%.1f",duranceForWhen,value);
    return value;
}

- (NSInteger)getItemLine:(NSInteger)index
{
    CGFloat maxWidth = CGFLOAT_MAX;
    NSInteger targetIndex = 0;
    NSInteger lineIndex = 0;
    for (NSNumber * number in lineRights ) {
        if([number floatValue] <maxWidth)
        {
            maxWidth = [number floatValue];
            targetIndex = lineIndex;
        }
        lineIndex ++;
    }
    return targetIndex;
    //    if(index >0)
    //    {
    //
    //    }
    //    else
    //    {
    //        return 0;
    //    }
}
#pragma mark - scroll
-(NSInteger)get_startVisibleIndex
{
    CGFloat offset = self.scrollOffset;
    NSInteger index = NSNotFound;
    NSArray * indexList = [[sizeSet_ allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSNumber * cIndex in indexList) {
        CGRect frame = CGRectFromString([sizeSet_ objectForKey:cIndex]);
        if((frame.origin.x <= offset && frame.origin.x + frame.size.width > offset)
           || (frame.origin.x > offset))
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
            insets.left = 0 - scrollOffset;
            self.contentInset = insets;
            CGPoint contentOffset =  CGPointMake(offsetTarget_,self.contentOffset.y);
            self.contentOffset = contentOffset;
        }
        else
        {
            
            UIEdgeInsets insets = self.contentInset;
            //            UIEdgeInsetsMake(0 - offsetTarget_, 0, 0, 0);
            if(insets.left>0)
            {
                insets.left = 0;
                self.contentInset = insets;
            }
            CGPoint contentOffset =  CGPointMake(offsetTarget_,self.contentOffset.y);
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

#pragma mark View loading
- (void)updateScrollViewDimensions
{
    CGFloat maxWidth = CGFLOAT_MIN;
    for (NSNumber * number in lineRights ) {
        if([number floatValue] > maxWidth)
        {
            maxWidth = [number floatValue];
        }
    }
//    NSLog(@"maxWidth = %.1f",maxWidth);
    if(self.contentSize.width < maxWidth)
    {
        self.contentSize = CGSizeMake( MAX(maxWidth,self.frame.size.width + self.leftMargin + self.rightMargin),self.frame.size.height );
    }
}

- (NSInteger)numberOfVisibleItems:(NSInteger *)indexBegin end:(NSInteger *)indexEnd
{
    if(self.dataSource)
    {
        totalCount_ = [self.dataSource commentListView:self numberOfItemsInSection:0];
    }
    
    CGFloat offsetMin = self.contentOffset.x - self.frame.size.width/4;
    CGFloat offsetMax = self.frame.size.width*5/4 + offsetMin;
    //    int multiple = (int)offsetMin / self.frame.size.width;
    if (self.contentOffset.x <= 0)
    {
        offsetMax = (self.frame.size.width + offsetMin) + offsetMin + self.frame.size.width/2;
    }
    //    else if (multiple%2)
    //    {
    //        offsetMax = self.frame.size.width*3/4 + offsetMin;
    //    }
    
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
        if(frame.origin.x +frame.size.width > offsetMin && *indexBegin <0)
        {
            // NSLog(@"offsetMin ============= %f",offsetMin);
            *indexBegin = index;
        }
        else if(frame.origin.x > offsetMax +frame.size.width )
        {
            *indexEnd = index-1;
            break;
        }
        
        if(frame.origin.x > offsetMax)
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
    
    //    CGFloat offsetX = self.contentOffset.x;
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
#pragma mark 新加入的需要像子弹一样滑入到屏幕区
                //                dispatch_async(dispatch_get_main_queue(), ^{
                
                [self addViewItem:view row:[number integerValue] animates:YES];
                //                });
                
            }
            if(self.dataSource && [self.dataSource respondsToSelector:@selector(commentListView:didEndDisplayCell:)])
            {
                [self.dataSource commentListView:self didEndDisplayCell:indexPath];
            }
        }
        
        //        if(view)
        //        {
        //            if(self.scrollByUser)
        //            {
        //                if(view.frame.origin.x < offsetX +100 && view.alpha >0)
        //                {
        //                    CGFloat alpha =  MIN(1,((offsetX - view.frame.origin.x)> view.frame.size.width?
        //                                            0
        //                                            :
        //                                            (1- (offsetX + 100 - view.frame.origin.x)/(view.frame.size.width+100))));
        //
        //                    view.alpha = alpha;
        //                    view.hidden = NO;
        //                }
        //                else
        //                {
        //                    view.alpha = 1;
        //                    view.hidden = NO;
        //                }
        //                [self showViewItem:view row:[number integerValue] animates:YES];
        //            }
        //            else if([view needHide:self.playerDuration])
        //            {
        //                //                NSLog(@"%f",self.playerDuration);
        //                //                NSLog(@"row:%d alpha:%0.1f  player:%f du:%0.1f ",view.row,view.alpha,self.playerDuration,view.Data.DuranceForWhen);
        //                //                view.alpha = 0;
        //                //                view.hidden = YES;
        //                [self hideViewItem:view row:[number integerValue] animates:YES];
        //            }
        //            else
        //            {
        //                if(view.frame.origin.x < offsetX +100)
        //                {
        //                    if(view.alpha>0)
        //                    {
        //                        CGFloat alpha =  MIN(1,((offsetX - view.frame.origin.x)> view.frame.size.width?
        //                                                0
        //                                                :
        //                                                (1- (offsetX + 100 - view.frame.origin.x)/(view.frame.size.width+100))));
        //
        //                        view.alpha = alpha;
        //                        view.hidden = NO;
        //                    }
        //                    [self showViewItem:view row:[number integerValue] animates:YES];
        //                }
        //                else if(view.alpha ==0 && view.staySeconds == -1)
        //                {
        //                    [self showViewItem:view row:view.row animates:YES];
        //                }
        //        //                         NSLog(@"view row:%d alpha:%0.1f stayseconds:%0.1f --",view.row,view.alpha,view.staySeconds);
        //            }
        //            //                if(self.scrollByUser)
        //            //                {
        //            //                    view.alpha = 1;
        //            //                }
        //            //                else if([view needHide:self.playerDuration])
        //            //                {
        //            //                    view.alpha = 0;
        //            //                }
        //            //
        //            //            }
        //
        //        }
        //
        //        //    NSLog(@" row:%d frame:%@ alpha:%0.1f offset:%0.1f",[number integerValue],NSStringFromCGRect(view.frame),view.alpha,self.scrollOffset +self.frame.size.height);
    }
}
- (void)addViewItem:(UIView *)view row:(NSInteger)row animates:(BOOL)animates
{
    CommentAnimateItem * item = [CommentAnimateItem new];
    item.row = row;
    item.duration = animates?0.5:0;
    item.viewObject = view;
    item.animateType = CommentSlideIn;
    [self addAnimateItem:item];
    //
    //    if(view.superview) return;
    //    [self addSubview:view];
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
    
    NSLog(@"---->  scroll to index %d,",indexPath.row);
    
    lastRow_ = indexPath.row;
    //    if(indexPath.row>=19)
    //    {
    //        NSLog(@"observer item alpha");
    //    }
    
    if(scrollPosition == UICollectionViewScrollPositionTop)
        offsetSpace = targetFrame.origin.x + targetFrame.size.width ;
    else
        offsetSpace = targetFrame.origin.x + targetFrame.size.width - self.frame.size.width;
    
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