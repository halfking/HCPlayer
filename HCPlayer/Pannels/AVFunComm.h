//
//  AVFunComm.h
//  Wutong
//
//  Created by HUANGXUTAO on 15/3/19.
//  Copyright (c) 2015年 HUANGXUTAO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface AVFunComm : NSObject
//取出第一帧
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;
+ (void) combinateAudio2Video:(NSURL *)audioUrl videoUrl:(NSURL *)videoUrl outputPath:(NSString *)outPath;

@end
