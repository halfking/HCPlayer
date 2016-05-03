//
//  WTVideoPlayerView(Cache).h
//  maiba
//
//  Created by HUANGXUTAO on 16/1/6.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTVideoPlayerView.h"


@interface WTVideoPlayerView(Cache)
- (void)playMTV:(MTV *)mtv seconds:(CGFloat)seconds;
- (void)playUrl:(NSURL *)url seconds:(CGFloat)seconds;
@end
