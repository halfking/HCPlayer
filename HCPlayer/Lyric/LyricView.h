//
//  LyricView.h
//  LyricsDemo
//
//  Created by seentech_5 on 15/9/7.
//  Copyright (c) 2015年 seentech_5. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LyricView : UIView
{
    
}
@property(nonatomic,strong) NSMutableArray *lrcArray;
@property(nonatomic,strong) NSMutableArray *timeArray;
@property(nonatomic,strong) NSArray * lrcItems;
@property(nonatomic,assign) CGFloat secondsForReady;//开始唱之前，准备的时间

// 初始化歌词
//- (instancetype)initWithFrame:(CGRect)frame lyric:(NSString *)lyric;
- (instancetype)initWithFrame:(CGRect)frame lyric:(NSString *)lyric singleRowShow:(BOOL)singleRowShow;

// 重置歌词
//- (void)setLyric:(NSString *)lyric;
- (void)setLyric:(NSString *)lyric singleRowShow:(BOOL)singleRowShow;

// 同步歌词
- (void)didPlayingWithSecond:(float)second;

// 歌词回滚到上一句歌词，并返回上一句歌词之前3秒的时间
- (float)getPreviousSecondWithCurrentSecond:(float)second;

@end
