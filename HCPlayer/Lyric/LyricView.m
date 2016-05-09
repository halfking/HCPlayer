//
//  LyricView.m
//  LyricsDemo
//
//  Created by seentech_5 on 15/9/7.
//  Copyright (c) 2015年 seentech_5. All rights reserved.
//

#import "LyricView.h"
#import <UIKit/UIKit.h>
#import <hccoren/base.h>
#import <HCMVManager/LyricHelper.h>
#import "player_config.h"
#import "LyricCell.h"
#import "LyricDragView.h"
#import <HCMVManager/LyricItem.h>

@interface LyricView ()<UITableViewDataSource,UITableViewDelegate>
{
    CGFloat rowH_;
    BOOL isSingleRow_;
    int dotCount_;
}

@property(nonatomic,strong) UITableView *lyricView;

@property(nonatomic,strong) NSIndexPath *indexPath;
@property(nonatomic,strong) UILabel *lrcLable;
@property(nonatomic,strong) UIView *countdownView;

@end

@implementation LyricView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        rowH_ = 30;// self.frame.size.height / 3;
        self.secondsForReady = 3.5;
        
        self.backgroundColor = [UIColor clearColor];
        self.lyricView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.lyricView.backgroundColor = [UIColor clearColor];
        [self addSubview:_lyricView];
        
        self.lyricView.dataSource = self;
        self.lyricView.delegate = self;
        self.lyricView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.lyricView.showsVerticalScrollIndicator = NO; // 取消垂直方向滚动指示
        self.lyricView.userInteractionEnabled = NO;
        
        self.lyricView.rowHeight = rowH_;
        
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, rowH_)];
        self.lyricView.tableHeaderView = header;
    }
    return self;
}
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.lyricView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}
- (instancetype)initWithFrame:(CGRect)frame lyric:(NSString *)lyric singleRowShow:(BOOL)singleRowShow
{
    self = [self initWithFrame:frame];
    [self setLyric:lyric singleRowShow:singleRowShow];
    
    return self;
}

- (void)setLyric:(NSString *)lyricUrlStr singleRowShow:(BOOL)singleRowShow
{
    if (!lyricUrlStr || lyricUrlStr.length < 5) {
        return;
    }
    isSingleRow_ = singleRowShow;
    self.lrcArray = [NSMutableArray array];
    self.timeArray = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self getLyricDataWithLyric:lyricUrlStr];
    });
    
    if (!isSingleRow_) {
        [self buildCountdownView];
        self.userInteractionEnabled = NO; // 关闭
    }
    else
    {
        self.userInteractionEnabled = NO; // 关闭
    }
}

- (void)getLyricDataWithLyric:(NSString *)lyric
{
    NSLog(@"%@",lyric);
    
    //如果是URL，则直接去取，如果是Json，直接处理
    if([HCFileManager isUrlOK:lyric])
    {
        self.lrcItems = [[LyricHelper sharedObject] setSongLrcWithUrl:lyric lycArray:self.lrcArray timeArray:self.timeArray];
    }
    else
    {
        self.lrcItems = [[LyricHelper sharedObject]getSongLrcWithStr:lyric metas:nil];
        //check 时间
        if(self.lrcArray)
            [self.lrcArray removeAllObjects];
        else
            self.lrcArray = [NSMutableArray new];
        if(self.timeArray)
            [self.timeArray removeAllObjects];
        else
            self.timeArray = [NSMutableArray new];
        for (LyricItem * item in self.lrcItems) {
            [self.lrcArray addObject:item.text?item.text:@""];
            [self.timeArray addObject:[NSString stringWithFormat:@"%.2f",item.begin]];
        }
        
    }
    if (!self.lrcArray || self.lrcArray.count == 0) {
        return;
    }
    
    
#pragma mark 暂时用来判断 以防前两句歌词不是空歌词
    // 如果第一句歌词不为空歌词
    NSString *firstLyric = [[self.lrcArray firstObject] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"firstLyric.length %d",(int)firstLyric.length);
    if (firstLyric.length >1)
    {
        [self.timeArray insertObject:@"0.00" atIndex:0];
        [self.lrcArray insertObject:@"" atIndex:0];
    }
    // 如果第二句歌词不为空歌词
    if (self.lrcArray.count > 1)
    {
        NSString *secondLyric = [self.lrcArray[1] stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (secondLyric.length >1)
        {
            [self.timeArray insertObject:@"1.00" atIndex:1];
            [self.lrcArray insertObject:@"" atIndex:1];
        }
    }
    // 如果最后一句歌词不为空歌词
    NSString *lastLyric = [[self.lrcArray lastObject] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (lastLyric.length >1)
    {
        NSString *lastTime = [self.timeArray lastObject];
        NSString *lastTimeNew = [NSString stringWithFormat:@"%.2f",(lastTime.floatValue + 6)];
        
        [self.timeArray addObject:lastTimeNew];
        [self.lrcArray addObject:@""];
    }
    
    
    if (self.timeArray.count > 0 && self.lrcArray.count > 0) {
        for (int i = 0; i < self.lrcArray.count; i++)
        {
            NSLog(@"%@ --- %@",self.timeArray[i],self.lrcArray[i]);
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.lyricView reloadData];
    });
    
}

- (void)didPlayingWithSecond:(float)second
{
    //return;
    if (!self.timeArray || self.timeArray.count < 3) {
        return;
    }
    [self showCountdownWithSecond:second];
    
    for (int i = 0; i < self.timeArray.count; i++)
    {
        float time = [self.timeArray[i] floatValue];
        
        // 最后一句歌词
        if (i == self.timeArray.count - 1)
        {
            if (second >= time)
            {
                [self selectNewLyricWithIndex:i];
                break;
            }
        }
        else
        {
            float nextTime = [self.timeArray[i+1] floatValue];
            
            if (second >= time && second <nextTime)
            {
                [self selectNewLyricWithIndex:i];
                break;
            }
        }
    }
}

// 根据时间 显示进唱倒计时
- (void)showCountdownWithSecond:(float)second
{
    
    if (!self.timeArray || self.timeArray.count < 3) {
        return;
    }
    float time = [self.timeArray[2] floatValue];
    float threeBef = roundf((time - 3)*10)/10;
    float fiveBef = roundf((time - 5)*10)/10;
    time = roundf(time * 10)/10;
    second = roundf(second * 10)/10;
    if (fiveBef > 0) {
        if (second == fiveBef) {
            [self showCountdownView];
        }
    } else if (threeBef > 0) {
        if (second == roundf(0.2*10)/10) {
            [self showCountdownView];
        }
    }
    
    if (second == threeBef) {
        [self startCountdown];
    }
    if (second == time) {
        [self stopCountdown];
    }
}

- (void)selectNewLyricWithIndex:(int)i
{
    if (i >= self.lrcArray.count) return;
    if (isSingleRow_)
    {
        if ([self.lrcLable.text isEqualToString:self.lrcArray[i]]) return;
        
        [UIView animateWithDuration:0.5 animations:^(void)
         {
             self.lrcLable.alpha = 0;
         }completion:^(BOOL completed)
         {
             [UIView animateWithDuration:1 animations:^(void)
              {
                  self.lrcLable.alpha = 1;
                  self.lrcLable.text = self.lrcArray[i];
              }completion:^(BOOL completed)
              {
                  
              }];
         }];
    }
    else
    {
        // 实现歌词显示和 LRCTableView 同步
        if (i == self.indexPath.row) return;
        
        self.indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self selectRowAtIndexPathWithAnimate:self.indexPath];
        [self.lyricView reloadData];
    }
}

- (void)selectRowAtIndexPathWithAnimate:(NSIndexPath *)indexPath
{
    if (!self.lrcArray || self.lrcArray.count == 0) return;
    if(self.lrcArray.count <= indexPath.row) return;
    if([self.lyricView numberOfRowsInSection:0] <= indexPath.row) return;
    
    [UIView animateWithDuration:0.3 animations:^(void)
     {
         [self.lyricView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
     }completion:^(BOOL completed)
     {
         
     }];
}

// 歌词回滚到上一句歌词的前三秒，上一句歌词的前三秒可能是再上一句歌词
- (float)getPreviousSecondWithCurrentSecond:(float)second
{
    if (isSingleRow_) {
        return -1;
    }
    if (!self.lrcArray || self.lrcArray.count == 0) {
        return -1;
    }
    
    NSLog(@"-----------------------------------------%d",(int)self.indexPath.row);
    float time;
    CGFloat secondsPrev = self.secondsForReady;
    if (self.indexPath.row == 0 || self.indexPath.row == 1) // 开头空歌词
    {
        if (self.timeArray.count == 0 || self.timeArray == nil) {
            time = 0;
        }
        else if(self.timeArray.count>2)
        {
            time = [self.timeArray[2] floatValue];
        }
        else
            time = 0;
        
        
        if (time - secondsPrev <= 0) {
            return 0;
        }
        else
            return second < (time - secondsPrev) ? 0 : (time - secondsPrev-0.1);
    }
    else if (self.indexPath.row == 2) // 第一句歌词
    {
        if (self.timeArray.count == 0 || self.timeArray == nil) {
            time = 0;
        }
        else if(self.timeArray.count>2)
            time = [self.timeArray[2] floatValue];
        else time = 0;
        
        return (time - secondsPrev - 0.1) <= 0 ? 0 : (time - secondsPrev - 0.1);
    }
    else //
    {
        NSString *time = self.timeArray[self.indexPath.row - 1];
        float t = (time.floatValue - secondsPrev - 0.1);
        
        return t;
    }
    
}


#pragma mark - UITableViewDataSourse
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isSingleRow_)
    {
        return 1;
    }
    else
    {
        return self.lrcArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isSingleRow_)
    {
        static NSString *cellIdentifier = @"singleLrcCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        if (!self.lrcLable)
        {
            self.lrcLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, rowH_)];
            self.lrcLable.textAlignment = NSTextAlignmentCenter;
            self.lrcLable.textColor = [UIColor whiteColor];
            // self.lrcLable.font = [UIFont systemFontOfSize:19];
            if ([DeviceConfig config].Height <= 568) {
                self.lrcLable.font = FONT_STANDARD(19);
            }
            else
            {
                self.lrcLable.font = FONT_TITLESOFSIZE(19);
            }
        }
        self.lrcLable.shadowOffset = CGSizeMake(1, 1);
        self.lrcLable.shadowColor = COLOR_BE;
        [cell.contentView addSubview:_lrcLable];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    
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
        cell.lrc.alpha = 0;
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
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isSingleRow_)
    {
        return self.bounds.size.height;
    }
    else
    {
        return rowH_;
    }
}


#pragma mark - countdown (进唱3秒倒计时)
- (void)buildCountdownView
{
    if (self.countdownView) return;
    
    CGFloat width = 60;
    self.countdownView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - width)/2, rowH_, width, rowH_)];
    [self addSubview:_countdownView];
    self.countdownView.alpha = 0;
    
    dotCount_ = 3;
    CGFloat singleWidth = 8;
    CGFloat space = (width - singleWidth * dotCount_) / (dotCount_ + 1);
    for (int i = 1; i <= dotCount_; i++) {
        UIView *singleView = [[UIView alloc] initWithFrame:CGRectMake(space*i + singleWidth*(i-1), (rowH_ - singleWidth)/2, singleWidth, singleWidth)];
        singleView.layer.masksToBounds = YES;
        singleView.layer.cornerRadius = singleWidth/2;
        singleView.backgroundColor = COLOR_BA;
        singleView.tag = 300+i;
        [self.countdownView addSubview:singleView];
        PP_RELEASE(singleView);
    }
}

- (void)showCountdownView
{
    self.countdownView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.countdownView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)startCountdown
{
    for (int i = dotCount_; i >= 1; i--)
    {
        [UIView animateWithDuration:1.0 delay:1.0*(dotCount_-i) options:0 animations:^{
            UIView *view = [self.countdownView viewWithTag:300+i];
            view.backgroundColor = [UIColor whiteColor];
            view.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)stopCountdown
{
    self.countdownView.alpha = 0;
    [UIView animateWithDuration:1.0 delay:1.0 options:0 animations:^{
        for (int i = dotCount_; i >= 1; i--)
        {
            UIView *view = [self.countdownView viewWithTag:300+i];
            view.backgroundColor = COLOR_BA;
            view.alpha = 1;
        }
    } completion:^(BOOL finished) {
        
    }];
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    
    if (hidden) {
        if (self.countdownView.alpha > 0) {
            [self stopCountdown];
        }
    }
}

@end
