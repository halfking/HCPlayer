//
//  WTVideoPlayerView(Lyric).h
//  maiba
//
//  Created by HUANGXUTAO on 16/1/6.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTVideoPlayerView.h"


@interface WTVideoPlayerView(Lyric)
- (void)showLyric:(NSString *)lyric singleLine:(BOOL)singleLine container:(UIView *)container;
- (void)resetLyricFrame:(CGRect)containerFrame;
- (void)showLyric;
- (void)hideLyric;
- (void)removeLyric;

- (void)initComments:(UIView *)container textContainer:(UIView *)textContainer inputTag:(int)inputTag objectType:(HCObjectType) objectType objectID:(long)objectID;
- (void)resetCommentsFrame:(CGRect)commentFamre container:(UIView *)container textContainer:(UIView *)textContainer;

- (void)refreshComment;
- (void)resetComments;

- (void)showComments;
- (void)hideComments;
- (void)refreshCommentsView:(CGFloat)durance;

- (void)removeComments;
@end
