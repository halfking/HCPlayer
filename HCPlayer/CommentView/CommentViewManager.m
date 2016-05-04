//
//  CommentViewManager.m
//  Wutong
//
//  Created by HUANGXUTAO on 15/7/28.
//  Copyright (c) 2015年 HUANGXUTAO. All rights reserved.
//

#import "CommentViewManager.h"
#import <HCBaseSystem/cmd_wt.h>
#import <HCBaseSystem/comments_wt.h>
#import "UICommentListView.h"
#import "UICommentsPopView.h"
@implementation CommentViewManager

static NSString * cellIdentifier =@"CommentListitem";
- (id)init
{
    self = [super init];
    if(self)
    {
        lastIndex_ = -1;
        currentDuranceWhen_ = -1;
        orgListViewFrame_ = CGRectZero;
        timerDoing_ = NO;
    }
    return self;
}
- (void)setObject:(HCObjectType)objectType objectID:(long)objectID
{
    objectType_ = objectType;
    objectID_ = objectID;
}
- (void)reset
{
    [self stopCommentTimer];
    if(self.commentListView_)
    {
        [self.commentListView_ reset];
    }
    
    [self setCommentBeginWhen:0];
    commentBeginWhen_ = 0;
    lastSecconds_ = 0;
    lastIndex_ = -1;
    [commentList_ removeAllObjects];
    [self setCurrentDuranceWhen:0];
    if (self.showType == CommentShowTypeList)
    {
        [self.commentListView_ setScrollOffset:0 - self.commentListView_.frame.size.height updateLayout:YES];
    }
    else
    {
        [self.commentListView_ setScrollOffset:0 - self.commentListView_.frame.size.width updateLayout:YES];
    }
}
- (void)readyToRelease
{
    if(self.commentListView_)
    {
        [self.commentListView_ clearAnimateItems];
    }
    [self stopCommentTimer];
}
- (void)setCurrentDuranceWhen:(CGFloat)seconds
{
    // NSLog(@"durations:%.1f",seconds);
    currentDuranceWhen_ = seconds;
    self.commentListView_.playerDuration = seconds;
    // NSLog(@"durations:%0.1f",self.commentListView_.playerDuration);
}
- (int)commentCount
{
    //    @synchronized(self)
    //    {
    return commentsTotalCount_;
//    return (int)commentList_.count;
    //    }
}
#pragma mark - buildComments
- (UICommentsView *)createCommentsView:(CGRect)frame
{
    if(self.showType == CommentShowTypeList)
    {
        UICommentListView * commentView = [[UICommentListView alloc]initWithFrame:frame ];// collectionViewLayout:layout];
        commentView.dataSource = self;
        commentView.delegate = self;
        //        commentView.backgroundColor = [UIColor clearColor];
        [commentView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        commentView.alwaysBounceVertical = YES;
        commentView.tag = COMMENTVIEW_TAG;
        commentView.verticalSpace = 5;
        commentView.leftMargin = 15;
        [commentView setScrollOffset:0 - frame.size.height updateLayout:YES];
        //    commentView.contentOffset = CGPointMake(0, 0 - frame.size.height);
        if(commentView.contentSize.height <= frame.size.height)
        {
            commentView.contentSize = CGSizeMake(commentView.contentSize.width, frame.size.height +20);
        }
        // commentView.userInteractionEnabled = YES;
        commentView.userInteractionEnabled = NO;
        
        self.commentListView_ = commentView;
        //    commentView.backgroundColor = [UIColor yellowColor];
        PP_RELEASE(commentView);
        return self.commentListView_;
    }
    else
    {
        UICommentsPopView * commentView = [[UICommentsPopView alloc]initWithFrame:frame ];// collectionViewLayout:layout];
        
        commentView.dataSource = self;
        commentView.delegate = self;
        commentView.backgroundColor = [UIColor clearColor];
        [commentView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        commentView.alwaysBounceHorizontal = YES;
        commentView.tag = COMMENTVIEW_TAG;
        commentView.itemSpace = 15;
        commentView.numberOfLines = 4;
        commentView.leftMargin = 15;
        [commentView setScrollOffset:0 - frame.size.width updateLayout:YES];
        
        if(commentView.contentSize.width <= frame.size.width)
        {
            commentView.contentSize = CGSizeMake(commentView.contentSize.width+20, frame.size.height);
        }
        commentView.userInteractionEnabled = NO;
        self.commentListView_ = commentView;
        PP_RELEASE(commentView);
        return self.commentListView_;
    }
}
- (void)refreshCommentsView:(CGFloat)durance reloadNow:(BOOL)reloadNow completed:(didRefreshComments)completed
{
    if (reloadNow)
    {
        [self reloadComments:durance completed:^(int code) {
            if (completed) {
                completed(code);
            }
        }];
    }
    else
    {
        BOOL reload = YES;
        if (commentList_.count > 15) {
            Comment *commentF = [commentList_ firstObject];
            Comment *commentN = [commentList_ objectAtIndex:commentList_.count-15];
            if (durance >= commentF.DuranceForWhen && durance <= commentN.DuranceForWhen) {
                reload = NO;
            }
        }
        if (!reload) {
            // 这个根据 计时器滚动的算法得出 当前播放时间 弹幕应该滚动的位置
            CGFloat value = durance * 150 - self.commentListView_.frame.size.width/2;
            [self.commentListView_ setScrollOffset:value updateLayout:NO];
            completed(0);
        } else {
            [self reloadComments:durance completed:^(int code) {
                if (completed) {
                    completed(code);
                }
            }];
        }
    }
}
- (void)reloadComments:(CGFloat)durance completed:(didRefreshComments)completed
{
    [self reset];
    // [self setObject:HCObjectTypeMTV objectID:currentMtv_.MTVID];
    [self setCommentBeginWhen:durance];
    [self getComments:0 completed:^(int code,long commentsCount,NSString * qaguid,NSString * msg)
     {
         if(completed)
         {
             completed(code);
         }
     }];
}
#pragma mark  - delegate
- (NSInteger)commentListView:(UICommentsView *)listView numberOfItemsInSection:(NSInteger)section
{
    @synchronized(self)
    {
        return commentList_.count;
    }
}

- (CGSize)commentListView:(UICommentsView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(self.commentListView_.frame.size.width - self.commentListView_.leftMargin - self.commentListView_.rightMargin, 30);
    Comment * item = [commentList_ objectAtIndex:indexPath.row];
    //    if(item.Content && item.Content.length >15)
    //    {
    CGFloat fontSize = 16.0f;
    if(self.showType == CommentShowTypeList)
    {
        fontSize = 12.0f;
    }
    CGFloat maxWidth = 1000; // 单行超长
    CGFloat maxheight = 90; // 可换行
    maxheight = 20; // 单行
    size = [item.Content boundingRectWithSize:CGSizeMake( MAX(size.width -35 -10,maxWidth), maxheight)
                                      options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}
                                      context:nil].size;
    if(self.showType == CommentShowTypeList)
    {
        size.width = roundf((size.width + 50)*2)/2.0f;
    }
    else
    {
        size.width = roundf((size.width + 20)*2)/2.0f;
    }
    size.height = roundf((size.height + 18)*2)/2.0f;
    //        size = [item.Content sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]}];
    if(size.height < 30)
    {
        size.height = 30;
    }
    //        NSLog(@"index:%d size:%@",indexPath.row,NSStringFromCGSize(size));
    //        else
    //        {
    //            size.height += 10;
    //        }
    //        if(size.width < self.commentListView_.frame.size.width)
    //        {
    //            size.width = self.commentListView_.frame.size.width;
    //        }
    //    }
    return size;
}

- (UICommentItemView *)commentListView:(UICommentsView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row > commentList_.count -1 || indexPath.row<0) return [UICommentItemView new];
    UICommentItemView * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (commentList_.count > 0)
    {
        Comment * item = [commentList_ objectAtIndex:indexPath.row];
        
        if(self.showType == CommentShowTypeList)
            [cell setData:item showAvatar:YES];
        else
            [cell setData:item showAvatar:NO];
    }
    
    cell.delegate = self.commentListView_;
    cell.row = indexPath.row;
    if(!commentScrollByUser_ && commentScrollByUserSeconds_ <=0)
    {
        if(refreshCommentView_)
        {
            cell.staySeconds = 0;
            [cell decTimer:NSNotFound];
            cell.staySeconds = -1;//-1表示初始化
        }
    }
    return cell;
}
- (void)commentListView:(UICommentsView *)listView didEndDisplayCell:(NSIndexPath *)indexPath
{
    int minCount = 3;
    if(self.showType == CommentShowTypePop)
    {
        minCount = 10;
    }
    if(hasMoreComments_ && indexPath.row == [self commentCount]-10)
    {
        [self getComments:-1 completed:^(int code,long commentsCount,NSString * qaguid,NSString * msg)
         {
             if(code==0)
             {
                 //                 [self refreshCommentsCount:commentsCount];
             }
         }];
        
    }
}

- (CGFloat)commentListView:(UICommentsView *)listView duranceForWhenForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Comment * item = [commentList_ objectAtIndex:indexPath.row];
    CGFloat durance = item.DuranceForWhen - commentBeginWhen_;
    return durance;
}

- (void)commentListView:(UICommentsView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //        [self showCommentDetail:indexPath];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    commentScrollByUser_ = YES;
    commentScrollByUserSeconds_ = SCROLLSTAY_SECONDS;
    self.commentListView_.scrollByUser = YES;
}
-(void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    if(!scrollByProgram_)
    {
        if(commentScrollByUser_ ||commentScrollByUserSeconds_>0)
        {
            if(commentList_.count>0)
            {
                for (UICommentItemView * cell in [self.commentListView_ visibleItemViews]) {
                    [cell resetTimer];
                    cell.staySeconds = SCROLLSTAY_SECONDS;
                }
            }
        }
    }
    //    [self.commentListView_ hideItemsOutScrollView];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    commentScrollByUser_ = NO;
    commentScrollByUserSeconds_ = SCROLLSTAY_SECONDS;
    //    self.commentListView_.scrollByUser = NO;
}
#pragma mark - data

- (void)setCommentBeginWhen:(CGFloat)durance
{
    commentBeginWhen_ = durance;
}

#pragma mark - add remove
- (void) addComments:(NSArray *)list pageIndex:(int)pageIndex
{
    if(!list || list.count==0) return;
    @synchronized(self)
    {
        if(pageIndex ==0)
        {
            [commentList_ removeAllObjects];
        }
        for (Comment * item in list) {
            [self addComment:item];
        }
    }
    //    [self.commentListView_ reloadData];
}
- (NSInteger)addComment:(Comment *)item
{
    NSLog(@"评论内容 %@ %.1f",item.Content,item.DuranceForWhen);
    
    if(!commentList_)
    {
        commentList_ = [NSMutableArray new];
    }
    NSInteger index = 0;
    for (Comment * currentItem in commentList_) {
        if(currentItem.QAID == item.QAID)
        {
            index = -1;
            break;
        }
        else if(currentItem.DuranceForWhen >item.DuranceForWhen)
        {
            break;
        }
        index ++;
    }
    //clear cache
    if(index>=0 && index<commentList_.count)
    {
        [commentList_ insertObject:item atIndex:index];
    }
    else if(index>=0)
    {
        [commentList_ addObject:item];
        index = commentList_.count -1;
    }
    if (index >= 0) {
        [self clearViewCache:index];
    }
    return index;
}
- (void)clearViewCache:(NSInteger)index
{
    [self.commentListView_ removeCache:index];
}
-(void) clearComments:(didClearComments)completed
{
    lastSecconds_ = 0;
    [commentList_ removeAllObjects];
    [self setCurrentDuranceWhen:0];
    
    if (self.showType == CommentShowTypeList)
    {
        [self.commentListView_ setScrollOffset:0 - self.commentListView_.frame.size.height updateLayout:YES];
    }
    else
    {
        [self.commentListView_ setScrollOffset:0 - self.commentListView_.frame.size.width updateLayout:YES];
    }
    //    self.commentListView_.contentOffset = CGPointMake(0,0 - self.commentListView_.frame.size.height);
    [self.commentListView_ reloadData];
    
    if(completed)
    {
        completed();
    }
}
- (BOOL)isHidden
{
    if(self.commentListView_ && self.commentListView_.hidden == NO
       && self.commentListView_.frame.origin.y <= 100)
    {
        return NO;
    }
    return YES;
}

- (void)commentsShowInThread:(CGFloat)progress time:(CGFloat)seconds animate:(BOOL)animate
{
//    if ([NSThread isMainThread]) {
//        [self commentsShow:progress time:seconds animate:animate];
//    }
//    else
//    {
//        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self commentsShow:progress time:seconds animate:animate];
//        });
//    }
}

- (void)commentsShow:(CGFloat)progress time:(CGFloat)seconds animate:(BOOL)animate
{
    CGFloat begin = 0;
    if(progress>0)
    {
        begin = progress;
    }
    else
    {
        begin = seconds;
    }
    // NSLog(@"progress %.2f",begin);
    begin = roundf(begin * 10)/10.0f;
    [self setCurrentDuranceWhen:begin];
    if(begin < lastSecconds_ + 0.4 && [self isHidden]==YES ) return;
    lastSecconds_ = begin;
    
    if(commentScrollByUser_ || commentScrollByUserSeconds_>0)
    {
        NSLog(@"scroll by user");
    }
    else
    {
        BOOL hasMoreSameTime = NO;
        NSInteger index = [self getNextCommentIndex:begin hasMoreSameTime:&hasMoreSameTime];
        while(index !=NSNotFound)
        {
            NSLog(@"add comment item:%ld",(long)index);
            lastIndex_ = index;
            //            CommentAnimateItem * item = [CommentAnimateItem new];
            //            item.row = index;
            //
            //            item.duration = 0;
            //
            //            item.viewObject = nil;
            //            item.animateType = CommentAdd;
            //            [self.commentListView_ addAnimateItem:item];
            
            CommentAnimateItem * item = [CommentAnimateItem new];
            item.row = lastIndex_;
            if(hasMoreSameTime)
                item.duration = 0.1;
            else
                item.duration = 0.35;
            
            item.viewObject = nil;
            item.animateType = CommentScroll;
            [self.commentListView_ addAnimateItem:item];
            
            item = [CommentAnimateItem new];
            item.row = index;
            
            if(hasMoreSameTime)
                item.duration = 0.1;
            else
                item.duration = 0.35;
            
            item.viewObject = nil;
            item.animateType = CommentShow;
            [self.commentListView_ addAnimateItem:item];
            
            //            NSLog(@"progress:%0.1f  seconds:%0.1f index:%d",progress,seconds,lastIndex_);
            
            if(!hasMoreSameTime)
                break;
            else
                index = [self getNextCommentIndex:begin hasMoreSameTime:&hasMoreSameTime];
        }
//        NSLog(@"no more comments to add");
    }
}
//按一般原则，是当前时间的评论，如果没有，则不处理。
//调度至少是1秒1次，因此获取数据，只显示当前秒至下一秒之间的数据的数据
- (NSInteger)getNextCommentIndex:(CGFloat)durationWhen hasMoreSameTime:(BOOL *)hasMoreSameTime
{
    NSInteger index = MAX(0,lastIndex_+1);
    for (;index < commentList_.count;index++) {
        Comment * item = [commentList_ objectAtIndex:index];
        //        NSLog(@"durationwhen:%0.1f bt [%0.1f,%0.1f) && %d > %d",item.DuranceForWhen,durationWhen,durationWhen+1,index,lastIndex_);
        
        //有部分数据的When是0，有可能就不会显示出来
        if((item.DuranceForWhen >= durationWhen || (item.DuranceForWhen <1 && durationWhen <1))
           && item.DuranceForWhen < durationWhen +1 && index > lastIndex_)
        {
            break;
        }
        else if(item.DuranceForWhen > durationWhen +1)
        {
            index = NSNotFound;
            break;
        }
    }
    
    if(index >=0 && index < commentList_.count)
    {
        if(index < commentList_.count-1)
        {
            Comment * item = [commentList_ objectAtIndex:index +1];
            //同一秒是否还有
            if(item.DuranceForWhen >= durationWhen && item.DuranceForWhen <= durationWhen +1)
            {
                * hasMoreSameTime = YES;
            }
            else
            {
                * hasMoreSameTime = NO;
            }
        }
        else
        {
            * hasMoreSameTime = NO;
        }
    }
    else
    {
        index = NSNotFound;
        //        NSLog(@"lastindex:%d",lastIndex_);
    }
    if((lastIndex_ >= (NSInteger)(commentList_.count-1)) && hasMoreComments_)
    {
        [self getComments:-1 completed:^(int code,long commentsCount,NSString * qaguid,NSString * msg)
         {
             if(code==0)
             {
             }
         }];
    }
    return index;
}
- (void)showCommentDetail:(NSIndexPath *)indexPath
{
    NSLog(@"show details for row:%d",(int)indexPath.row);
}

#pragma mark - datasource
-(BOOL)sendComment:(Comment *) comment completed:(didSendComment)completed
{
    
    if([comment.Content isEqualToString:@""]) return NO;
    
    CMD_CREATE(cmd, Comment, @"Comment");
    cmd.commentItem = comment;
    
    cmd.CMDCallBack= ^(HCCallbackResult * result)
    {
        if(result.Code==0)
        {
            // 便于显示 添加时间发送完就显示出来
            comment.DuranceForWhen = currentDuranceWhen_;
            // 标志 便于判断是否是用户刚发的评论
            comment.CreateUser = -1;
            [self addComment:comment];
            
            //            NSInteger index = [self addComment:comment];
            //            if(index >=0)
            //            {
            //                self.commentListView_.userInteractionEnabled = YES;
            //                [self.commentListView_ scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            //                [self refreshCommentsView:YES reset:NO andIndex:index];
            //            }
        }
        if(completed)
        {
            NSString *Qa_Identity = [result.DicNotParsed objectForKey:@"qa_identity"];
            completed(result,commentList_.count,Qa_Identity);
        }
    };
    
    return [cmd sendCMD];
}

- (void)refreshCommentsViewInThread:(BOOL)full reset:(BOOL)reset andIndex:(NSInteger)index
{
    if ([NSThread isMainThread]) {
        [self refreshCommentsView:full reset:reset andIndex:index];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self refreshCommentsView:full reset:reset andIndex:index];
        });
    }
}

- (void)refreshCommentsView:(BOOL)full reset:(BOOL)reset andIndex:(NSInteger)index
{
    if(reset && !full)
    {
        if (self.showType == CommentShowTypeList)
        {
            [self.commentListView_ setScrollOffset:0 - self.commentListView_.frame.size.height updateLayout:NO];
        }
        else
        {
            [self.commentListView_ setScrollOffset:0 - self.commentListView_.frame.size.width updateLayout:NO];
        }
        lastIndex_ = -1;
        currentDuranceWhen_ = -1;
    }
    
    if(full)
    {
        refreshCommentView_ = YES;
        //        [self.commentListView_ setScrollOffset:0 - self.commentListView_.frame.size.height updateLayout:NO];
        //        [NSTimer scheduledTimerWithTimeInterval:0.1
        //                                         target:self
        //                                       selector:@selector(resetFlags:)
        //                                       userInfo:nil
        //                                        repeats:NO];
        //
        //        NSLog(@"listView frame:%@,  hidden:%d",NSStringFromCGRect(self.commentListView_.frame),self.commentListView_.hidden);
    }
    else
    {
        [self.commentListView_ updateScrollViewDimensions];
    }
    if(index >=0 && index < commentList_.count)
    {
        //        [self.commentListView_ scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]
        //                                      atScrollPosition:UICollectionViewScrollPositionBottom
        //                                              animated:NO];
    }
}

//- (void)resetFlags:(NSTimer *)timer
//{
//    refreshCommentView_ = NO;
//    self.commentListView_.hidden = NO;
//    [self.commentListView_ setScrollOffset:0 - self.commentListView_.frame.size.height updateLayout:NO];
////    self.commentListView_.contentOffset = CGPointMake(0, 0 - self.commentListView_.frame.size.height);
//
//    for (UICommentItemView * cell in [self.commentListView_ visibleItemViews]) {
//        if(commentScrollByUser_)
//        {
//            cell.staySeconds = SCROLLSTAY_SECONDS;
//        }
//        else
//        {
//            Comment * item = cell.Data;
//            CGFloat dd =  roundf(item.DuranceForWhen - currentDuranceWhen_);
//            if( dd < -5 && cell.staySeconds >0)
//            {
//                cell.staySeconds = 1;
//                [cell decTimer:1000000];
//            }
//            else if(dd > 5 && cell.staySeconds >0)
//            {
//                cell.staySeconds = 1;
//                [cell decTimer:1000000];
//            }
//            else if(cell.staySeconds <0)//-1表示初始化
//            {
//                [cell resetTimer];
//                //                cell.staySeconds = 5 - abs((int)dd);
//            }
//            else
//            {
//                cell.staySeconds = STAY_SECONDS - abs((int)dd);;
//            }
//        }
//    }
//}
- (void)getComments:(int)pageIndex completed:(didGetComments)completed
{
    CMD_CREATE(cmd, GetMtvComments, @"GetMtvComments");
    cmd.ObjectID = objectID_;
    cmd.ObjectType = objectType_;
    if(pageIndex == -1)
    {
        pageIndex = (int)(commentList_.count / 30);
        //        if(pageIndex * pageSize >commentList_.count)
        //        {
        //            pageIndex ++;
        //        }
    }
    cmd.OrderType = 2;
    cmd.Durance = commentBeginWhen_;
    cmd.PageIndex = pageIndex;
    cmd.PageSize = 30;
    
    cmd.CMDCallBack= ^(HCCallbackResult * result)
    {
        if(result.Code==0 && result.List)
        {
            if(pageIndex==0)
            {
                [self clearComments:nil];
            }
            if(result.List.count >0)
            {
                [self addComments:result.List pageIndex:pageIndex];
                // self.commentListView_.userInteractionEnabled = YES;
            }
            else if(pageIndex==0)
            {
                // self.commentListView_.userInteractionEnabled=NO;
            }
            if(commentList_.count < result.TotalCount && result.List.count==cmd.PageSize)
            {
                hasMoreComments_  = YES;
            }
            else
            {
                hasMoreComments_ = NO;
            }
            commentsTotalCount_ = result.TotalCount;
            
            if(pageIndex==0)
                [self refreshCommentsViewInThread:YES reset:YES andIndex:0];
            else
                [self refreshCommentsViewInThread:NO reset:NO andIndex:-1];
        }
        if(completed)
        {
            completed(result.Code,MAX((int)commentList_.count,result.TotalCount),nil,result.Msg);
        }
    };
    
    [cmd sendCMD];
}
-(void)getMtvComments:(long) MTVID  pageSize:(int)pageSize pageIndex:(int)pageIndex completed:(didGetComments)completed
{
    
    CMD_CREATE(cmd, GetMtvComments, @"GetMtvComments");
    cmd.ObjectID = MTVID;
    cmd.ObjectType = HCObjectTypeMTV;
    if(pageIndex == -1)
    {
        pageIndex = (int)(commentList_.count / pageSize);
        //        if(pageIndex * pageSize >commentList_.count)
        //        {
        //            pageIndex ++;
        //        }
    }
    cmd.OrderType = 2;
    cmd.Durance = commentBeginWhen_;
    cmd.PageIndex = pageIndex;
    cmd.PageSize = pageSize;
    
    cmd.CMDCallBack= ^(HCCallbackResult * result)
    {
        if(result.Code==0 && result.List)
        {
            if(pageIndex==0)
            {
                [self clearComments:nil];
            }
            if(result.List.count >0)
            {
                [self addComments:result.List pageIndex:pageIndex];
                //                self.commentListView_.userInteractionEnabled = YES;
            }
            else if(pageIndex==0)
            {
                //                self.commentListView_.userInteractionEnabled=NO;
            }
            if(commentList_.count < result.TotalCount)
            {
                hasMoreComments_  = YES;
            }
            else
            {
                hasMoreComments_ = NO;
            }
            if(pageIndex==0)
                [self refreshCommentsViewInThread:YES reset:YES andIndex:0];
            else
                [self refreshCommentsViewInThread:NO reset:NO andIndex:-1];
        }
        if(completed)
        {
            completed(result.Code,MAX((int)commentList_.count,result.TotalCount),nil,result.Msg);
        }
    };
    
    [cmd sendCMD];
}

#pragma mark - hide
- (void)hide:(BOOL)animates
{
    //    self.commentListView_.hidden = YES;
    if(!self.commentListView_) return;
    
    CGRect frame = self.commentListView_.frame;
    
    //横屏
    //    CGFloat width = [DeviceConfig config].Height;
    CGFloat height = [DeviceConfig config].Width;
    
    [self stopCommentTimer];
    
    if(frame.origin.y < height)
    {
        //        orgListViewFrame_ = frame;
        
        //        frame.origin.x = width;
        frame.origin.y = height;
        if(animates)
        {
            [UIView animateWithDuration:0.3 animations:^(void)
             {
                 self.commentListView_.frame = frame;
             } completion:^(BOOL finished){
                 self.commentListView_.hidden = YES;
             }];
        }
        else
        {
            self.commentListView_.frame = frame;
            //此处不能直接Hidden，否则动画可能看不到
            
        }
    }
}
- (void)show:(BOOL)animates
{
    //        self.commentListView_.hidden = NO;
    if(!self.commentListView_) return;
    
    CGRect frame = self.commentListView_.frame;
    //横屏
    //    CGFloat width = [DeviceConfig config].Height;
    CGFloat height = [DeviceConfig config].Width;
    
    if(frame.origin.y >= height)
    {
        //        if(CGRectIsEmpty(orgListViewFrame_))
        //        {
        frame.origin.x = 0;
        //居中
        if(self.showType==CommentShowTypeList)
            frame.origin.y = 44;
        else
            frame.origin.y = (height - frame.size.height)/2.0f;
        //        }
        //        else
        //        {
        //            frame = orgListViewFrame_;
        //        }
        if(animates)
        {
            [UIView animateWithDuration:0.3 animations:^(void)
             {
                 self.commentListView_.frame = frame;
             }];
        }
        else
        {
            self.commentListView_.frame = frame;
        }
    }
}
- (void)decCommentShowSecond:(NSTimer *)timer
{
    if(commentScrollByUser_ ||commentScrollByUserSeconds_ >0)
    {
        commentScrollByUserSeconds_ --;
        if(commentScrollByUserSeconds_<=0)
        {
            commentScrollByUser_ = NO;
            self.commentListView_.scrollByUser = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshCommentsViewInThread:YES reset:NO andIndex:lastIndex_];
            });
            //            [self.commentListView_ reloadData];
        }
        return;
    }
    else
    {
        [self.commentListView_ doAnimates:nil];
//        NSLog(@"check timer hidden");
//        CGFloat playerSeconds = currentDuranceWhen_;
//        NSArray * array = [self.commentListView_ visibleItemViews];
//        if(self.showType == CommentShowTypeList)
//        {
//            CGFloat offsetBottom = self.commentListView_.scrollOffset + self.commentListView_.frame.size.height;
//            for (UICommentItemView * cell in array) {
////                NSLog(@"%f",cell.frame.origin.y);
//                if(cell.staySeconds <0)//-1表示初始化
//                {
//                    [cell resetTimer];
//                }
//                else if(cell.frame.origin.y < offsetBottom) //在底部不可见区域的，不用自动减
//                {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [cell decTimer:playerSeconds];
//                    });
//                }
//            }
//        }
//        else
//        {
//            //自动向左移指定像素，这里可能与子对像的加入有关系，不然，刚一加入就消失了？
//            [self.commentListView_ scrollByOffset:5 duration:0.02];
//        }
        
        //自动向左移指定像素，计时器调整偏移量
        [self.commentListView_ scrollByOffsetInThread:3.0 duration:0.02];
        [self.commentListView_ doAnimates:nil];
    }
}
- (void)startCommentTimer
{
    if(!timerDoing_)
    {
        if(!self.commentHideTimer_)
        {
            self.commentHideTimer_ = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(decCommentShowSecond:) userInfo:nil repeats:YES];
        }
        self.commentHideTimer_.fireDate = [NSDate distantPast];//
        timerDoing_ = YES;
    }
}
- (void)stopCommentTimer
{
    if(timerDoing_)
    {
        self.commentHideTimer_.fireDate = [NSDate distantFuture];//暂停定时器，注意不能调用invalidate方法，此方法会取消，之后无法恢复
        commentScrollByUserSeconds_ = 0;
        commentScrollByUser_ = NO;
        self.commentListView_.scrollByUser=NO;
        timerDoing_ = NO;
    }
}
@end
