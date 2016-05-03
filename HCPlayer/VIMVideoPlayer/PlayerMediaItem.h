//
//  PlayerMediaItem.h
//  maiba
//
//  Created by HUANGXUTAO on 15/9/7.
//  Copyright (c) 2015年 seenvoice.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <hccoren/base.h>
#import <HCBaseSystem/PublicEnum.h>

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define VIDEO_CTTIMESCALE 600 //apple recommed

@interface PlayerMediaItem : NSObject

@property (nonatomic,PP_STRONG) NSURL * url;            //播放路径
@property (nonatomic,PP_STRONG) NSString * path;        //播放的文件名（不含路径）
@property (nonatomic,PP_STRONG) ALAsset * originAsset;
@property (nonatomic,PP_STRONG) NSString * cover;
@property (nonatomic,assign) CGFloat prevSecondsInArray;//在队列中的起始时间
@property (nonatomic,assign) CMTime duration; //整个媒体的长度，如果是图片，这里表示图片的播放时间
@property (nonatomic,assign) CMTime begin;//加入到队列中时，该视频的起点时间，如果为图片，这里为0
@property (nonatomic,assign) CMTime end;//加入到队列中时，该视频的结束时间，如果为图片，这里为播放时长
@property (nonatomic,assign) CMTime transBegin;//原始播放包含转场的时间
@property (nonatomic,assign) CMTime transEnd;//原始播放包含转场的时间
//@property (nonatomic,assign) BOOL isImg;//是图片还是视频
@property (nonatomic,assign) CGFloat playRate;//播放速度
@property (nonatomic,assign) CGSize renderSize;//播放大小
@property (nonatomic,assign) CGFloat currentSecondsPlaying;//当前播放的位置
@property (nonatomic,assign) MediaItemInQueueType isTrans;//是否转场,//是图片还是视频

@property (nonatomic,assign) BOOL isGenerate;   //是否已经生成了
//相关对像
@property (nonatomic,PP_STRONG) PlayerMediaItem * prevItem;
@property (nonatomic,PP_STRONG) PlayerMediaItem * nextItem;

@property (nonatomic,assign) CutInOutMode modalType;
@property (nonatomic,assign) CutInOutMode modalInType;
@property (nonatomic,assign) CutInOutMode modalOnType;
@property (nonatomic,assign) CutInOutMode modalOffType;
@property (nonatomic,readwrite) MediaItemInQueueType originType;
@end
