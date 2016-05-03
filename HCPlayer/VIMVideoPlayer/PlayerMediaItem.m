//
//  PlayerMediaItem.m
//  maiba
//
//  Created by HUANGXUTAO on 15/9/7.
//  Copyright (c) 2015年 seenvoice.com. All rights reserved.
//

#import "PlayerMediaItem.h"

@implementation PlayerMediaItem
@synthesize url,cover;
@synthesize duration,begin,end,playRate,renderSize;
@synthesize currentSecondsPlaying;
@synthesize prevSecondsInArray;
@synthesize path;
@synthesize originAsset;
@synthesize originType;
@synthesize isTrans;
@synthesize prevItem,nextItem;
@synthesize transBegin,transEnd,isGenerate;
- (void)dealloc
{
    PP_RELEASE(prevItem);
    PP_RELEASE(nextItem);
    PP_RELEASE(path);
    PP_RELEASE(originAsset);
    PP_RELEASE(url);
    PP_RELEASE(cover);
    PP_SUPERDEALLOC;
}
@end
