//
//  LyricDragView.m
//  maiba
//
//  Created by seentech_5 on 15/11/17.
//  Copyright © 2015年 seenvoice.com. All rights reserved.
//

#import "LyricDragView.h"
#import <hccoren/base.h>
#import <player_config.h>
#import "LyricCell.h"

@interface LyricDragView ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *lrcView_;
    CGFloat rowHeight_;
    NSInteger currentRow_;
    BOOL needAutoHide_;
    NSInteger maxEnabledRow_;
    UIButton *singback_;
}
@property(nonatomic,strong) NSIndexPath *indexPath;
@property(nonatomic,strong) NSArray *lrcArray;
@property(nonatomic,strong) NSArray *timeArray;
@end

@implementation LyricDragView

- (instancetype)init
{
    CGFloat width = [DeviceConfig config].Height;
    CGFloat height = [DeviceConfig config].Width;
    
    return [self initWithFrame:CGRectMake(0, 0, width, height)];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    CGSize size = CGSizeMake(frame.size.width, frame.size.height);
    return [self initWithFrame:frame lyricViewSize:size];
}
- (instancetype)initWithFrame:(CGRect)frame lyricViewSize:(CGSize)lyricViewSize
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideLyricDragView)];
        [self addGestureRecognizer:tap];
        PP_RELEASE(tap);
        
        [self buildLyricView:lyricViewSize];
        
        singback_ = [UIButton buttonWithType:UIButtonTypeCustom];
        singback_.frame = CGRectMake((self.frame.size.width- 60), (self.frame.size.height-40)/2, 40, 40);
        [singback_ setImage:[UIImage imageNamed:@"singback"] forState:UIControlStateNormal];
        [singback_ addTarget:self action:@selector(singback:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGFloat left = lrcView_.frame.origin.x;

    lrcView_.frame = CGRectMake(left, 0, frame.size.width - 2 * left,frame.size.height);
}
- (void)buildLyricView:(CGSize)lyricViewSize
{
    lrcView_ = [[UITableView alloc] initWithFrame:CGRectMake((self.frame.size.width-lyricViewSize.width)/2, 0, lyricViewSize.width, lyricViewSize.height)];
    [self addSubview:lrcView_];
    lrcView_.delegate = self;
    lrcView_.dataSource = self;
    lrcView_.backgroundColor = [UIColor clearColor];
    lrcView_.showsVerticalScrollIndicator = NO; // 取消垂直方向滚动指示
    lrcView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    rowHeight_ = 44;
    
    UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,lyricViewSize.width, (lyricViewSize.height-rowHeight_)/2)];
    lrcView_.tableHeaderView = emptyView;
    lrcView_.tableFooterView = emptyView;
    
}
- (void)setIsSample:(BOOL)isSample
{
    _isSample = isSample;
    if (isSample) {
        [self addSubview:singback_];
    } else {
        [singback_ removeFromSuperview];
    }
}
- (void)setLyricDataWithLyricArray:(NSArray *)lyricArray timeArray:(NSArray *)timeArray
{
    self.lrcArray = lyricArray;
    self.timeArray = timeArray;
}
- (void)setCurrentSecond:(CGFloat)second
{
    if (!self.timeArray || self.timeArray.count == 0) return;
    if (self.hidden) {
        self.hidden = NO;
    }
    for (int i = 0; i < self.timeArray.count; i++) {
        CGFloat time = [self.timeArray[i] floatValue];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        if (i == self.timeArray.count-1)
        {
            if (second >= time) {
                [lrcView_ selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
                self.indexPath = indexPath;
                singback_.hidden = YES;
                break;
            }
        }
        else
        {
            CGFloat nexttime = [self.timeArray[i+1] floatValue];
            if (second>=time && second<nexttime) {
                [lrcView_ selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
                self.indexPath = indexPath;
                if (i<2) {
                    singback_.hidden = YES;
                } else {
                    singback_.hidden = NO;
                }
                break;
            }
        }
    }
    [lrcView_ reloadData];
}
- (void)setMaxEnabledRow:(CGFloat)second
{
    if (!self.timeArray || self.timeArray.count < 3) return;
    
    if (second < 0) {
        maxEnabledRow_ = -1;
        return;
    }
    for (int i = 0; i < self.timeArray.count; i++) {
        CGFloat time = [self.timeArray[i] floatValue];
        if (i == self.timeArray.count - 1) {
            if (second >= time) {
                maxEnabledRow_ = i;
                return;
            }
        }
        else {
            CGFloat nexttime = [self.timeArray[i+1] floatValue];
            if (second >= time && second < nexttime) {
                maxEnabledRow_ = i;
                return;
            }
        }
    }
    
}

- (void)singback:(id)sender
{
    if (!self.isSample) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(lyricDragViewWillBeginSingBack:)]) {
        [self.delegate lyricDragViewWillBeginSingBack:self];
    }
    
    UIAlertView * alterView = [[UIAlertView alloc]initWithTitle:MSG_PROMPT message:@"您确定要从此处开始重唱吗？" delegate:self cancelButtonTitle:EDIT_CANCEL otherButtonTitles:EDIT_OK, nil];
    alterView.tag = 50010;
    [alterView show];
    PP_RELEASE(alterView);
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 50010)
    {
        if (buttonIndex == alertView.cancelButtonIndex) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(lyricDragViewWillHide:)]) {
                [self.delegate lyricDragViewWillHide:self];
            }
        } else {
            if (currentRow_ >= self.timeArray.count) return;
            CGFloat time = [self.timeArray[currentRow_] floatValue] + 0.01f;
            time -= 3;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(lyricDragViewdidSingBack:atSecond:)]) {
                [self.delegate lyricDragViewdidSingBack:self atSecond:time];
            }
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.lrcArray.count>0) {
        return self.lrcArray.count;
    }
    else
    {
        return 1;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LyricCell *cell = [LyricCell initWithTableView:tableView indexPath:indexPath];
    cell.lrc.frame = cell.bounds;
    
    if (indexPath.row == self.indexPath.row)
    {
        cell.lrc.alpha = 1.0;
        if ([DeviceConfig config].Height <= 568) {
            cell.lrc.font = FONT_STANDARD(19);
        }
        else
        {
            cell.lrc.font = FONT_TITLESOFSIZE(19);
        }
        cell.lrc.textColor = COLOR_BA;
    }
    else if (indexPath.row < self.indexPath.row)
    {
        cell.lrc.alpha = 0.7;
        if ([DeviceConfig config].Height <= 568) {
            cell.lrc.font = FONT_STANDARD(14);
        }
        else
        {
            cell.lrc.font = FONT_TITLESOFSIZE(14);
        }
        cell.lrc.textColor = [UIColor whiteColor];
    }
    else
    {
        cell.lrc.alpha = 0.7;
        if ([DeviceConfig config].Height <= 568) {
            cell.lrc.font = FONT_STANDARD(14);
        }
        else
        {
            cell.lrc.font = FONT_TITLESOFSIZE(14);
        }
        cell.lrc.textColor = [UIColor whiteColor];
    }
    if (maxEnabledRow_>0) {
        if (indexPath.row >= (maxEnabledRow_+1)) {
            cell.lrc.textColor = [UIColor lightGrayColor];
        }
    }
    cell.lrc.shadowOffset = CGSizeMake(1, 1);
    cell.lrc.shadowColor = COLOR_BE;
    if(indexPath.row>= self.lrcArray.count)
    {
        NSLog(@"lyric row beyound bounds");
    }
    else
    {
        cell.lrc.text = [self.lrcArray objectAtIndex:indexPath.row];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
#pragma mark - Scroll
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    needAutoHide_ = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(lyricDragViewWillBeginDragging:)])
    {
        [self.delegate lyricDragViewWillBeginDragging:self];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = lrcView_.contentOffset.y;
    
    if (offsetY < 0) {
        //        offsetY *= -1;
        //        self.frame = CGRectMake(0, offsetY, self.frame.size.width, self.frame.size.height);
        return;
    }
    else
    {
        //        self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        
        if (maxEnabledRow_ >= 0 && offsetY >= (maxEnabledRow_+0.5)*rowHeight_)
        {
            lrcView_.contentOffset = CGPointMake(lrcView_.contentOffset.x, (maxEnabledRow_+0.5)*rowHeight_);
            return;
        }
        
        currentRow_ = (int)offsetY/rowHeight_;
        if (currentRow_ >= self.timeArray.count) return;
        
        if (currentRow_ < 2 || currentRow_ == self.timeArray.count-1) {
            singback_.hidden = YES;
        } else {
            singback_.hidden = NO;
        }
        
        self.indexPath = [NSIndexPath indexPathForRow:currentRow_ inSection:0];
        [lrcView_ reloadData];
        
        CGFloat time = [self.timeArray[currentRow_] floatValue];
        if (currentRow_ < self.timeArray.count-1) {
            CGFloat nextTime = [self.timeArray[currentRow_+1] floatValue];
            CGFloat realtime = ((float)(offsetY - rowHeight_*currentRow_)/rowHeight_)*(nextTime-time);
            time += realtime;
        }
        time = (time>0)?time:0;
        if (self.delegate && [self.delegate respondsToSelector:@selector(lyricDragViewDidScroll:second:)])
        {
            [self.delegate lyricDragViewDidScroll:self second:time];
        }
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self didEndDecelerating];
    }
    else
    {
        CGPoint offset = lrcView_.contentOffset;
        if (offset.y < -100)
        {
            [self hideLyricDragView];
/*
//            // 尝试解决下拉歌词tableView self.frame跟着下拉 松手后动画隐藏 现在无用
//            UIEdgeInsets insets = lrcView_.contentInset;
//            NSLog(@"%.f",insets.top);
//            if (insets.top > 0) {
//                offset.y = 0;
//            }
//            lrcView_.contentOffset = offset;
*/
//            needAutoHide_ = YES;
        }
//        else {
//            needAutoHide_ = NO;
//        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    if (!needAutoHide_) {
//        [self hideLyricDragView];
//    }
    [self didEndDecelerating];
}

- (void)didEndDecelerating
{
    [lrcView_ setContentOffset:CGPointMake(lrcView_.contentOffset.x, (currentRow_)*rowHeight_) animated:YES];
    
    if (currentRow_ >= self.timeArray.count) return;
     //  + 0.01f 防止返回时间精确度的误差 导致选择歌词行数不对
    CGFloat time = [self.timeArray[currentRow_] floatValue] + 0.01f;
    if (self.isSample && !self.isPreviewing) {
        time -= 3;
    }
    if ([self.lrcArray[currentRow_] length] < 2) {
        time = -1;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(lyricDragViewDidEndDecelerating:second:)])
    {
        [self.delegate lyricDragViewDidEndDecelerating:self second:time];
    }
}
- (void)endDecelerate
{
    lrcView_.decelerationRate = 0;
}
- (void)reloadData
{
    [lrcView_ reloadData];
}

- (void)hideLyricDragView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(lyricDragViewWillHide:)]) {
        [self.delegate lyricDragViewWillHide:self];
    }
}

@end
