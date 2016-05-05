//
//  WTVideoPlayerView(MTV).m
//  maiba
//
//  Created by HUANGXUTAO on 16/1/20.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import "WTVideoPlayerView(MTV).h"
#import "WTVideoPlayerView.h"
#import "WTVideoPlayerView(Cache).h"
#import <hccoren/base.h>
#import <HCBaseSystem/UpDown.h>
#import <HCBaseSystem/VDCManager(Helper).h>
#import <HCBaseSystem/VDCManager(LocalFiles).h>
#import <HCBaseSystem/VDCManager.h>
#import <HCMVManager/MTVUploader.h>
#import <HCBaseSystem/User_WT.h>


@implementation WTVideoPlayerView(MTV)

//检查文件是否存在，并且检查是否下载完成了
+ (BOOL)isDownloadCompleted:(MTV **)orgItem Sample:(MTV*)sample NetStatus:(NetworkStatus)status UserID:(long)userID
{
    NSString * path = nil;
    NSString * remoteUrl = nil;
    UDManager * ud = [UDManager sharedUDManager];
    MTV * item = *orgItem;
    
    path = [item getMTVUrlString:status userID:userID remoteUrl:&remoteUrl];
    
    //用户的视频没有上传，本地又不存在，则导致信失去
    if ((!path || path.length==0)&& item.MTVID!= 0 && sample)
    {
        NSString * audioPath = [item getAudioUrlString];
        NSString * orgAudioUrl = item.AudioRemoteUrl;
        
        
        //用用户唱过的替换原来的东东
        if(audioPath && audioPath.length>0)
        {
            UInt64 size = 0;

            if([ud isFileExistAndNotEmpty:audioPath size:&size])
            {
                [item setAudioPathN:audioPath];
                item.AudioRemoteUrl = orgAudioUrl;
            }
            else if([HCFileManager checkUrlIsExists:orgAudioUrl contengLength:nil level:nil])
            {
                item.AudioRemoteUrl = audioPath;
                [item setAudioPathN:nil];
            }
            else
            {
                item.AudioRemoteUrl = nil;
                [item setAudioPathN:nil];
            }
            
            item.DownloadUrl720 = sample.DownloadUrl720;
            item.DownloadUrl = sample.DownloadUrl;
            item.DownloadUrl360 = sample.DownloadUrl360;
            [item setFilePathN:sample.FileName];// [ud getFileName:sample.FilePath];
        }
        else
        {
            item = [sample copyItem];
            if(item.AudioFileName && item.AudioFileName.length>0)
            {
                UInt64 size = 0;
//                NSString * newPath = nil;
                
                if(![ud isFileExistAndNotEmpty:[item getAudioPathN] size:&size])
                {
                    [item setAudioPathN:nil];
                }
            }
            else if(item.AudioRemoteUrl)
            {
                if([HCFileManager checkUrlIsExists:item.AudioRemoteUrl contengLength:nil level:nil])
                {
                    
                }
                else
                {
                    item.AudioRemoteUrl = nil;
                }
            }
        }
        path = [item getMTVUrlString:status userID:userID remoteUrl:&remoteUrl];
    }
    if(!sample && item.AudioRemoteUrl)
    {
        NSString * audioPath = [item getAudioUrlString];
        NSString * orgAudioUrl = item.AudioRemoteUrl;
        
        
        //用用户唱过的替换原来的东东
        if(audioPath && audioPath.length>0)
        {
            UInt64 size = 0;
            
            if([ud isFileExistAndNotEmpty:audioPath size:&size])
            {
                [item setAudioPathN:audioPath];
                item.AudioRemoteUrl = orgAudioUrl;
            }
            else if([HCFileManager checkUrlIsExists:orgAudioUrl contengLength:nil level:nil])
            {
                item.AudioRemoteUrl = audioPath;
                [item setAudioPathN:nil];
            }
            else
            {
                item.AudioRemoteUrl = nil;
                [item setAudioPathN:nil];
            }
        }
    }
    if([HCFileManager isLocalFile:path])
    {
        UInt64 size = 0;
        
        if([ud isFileExistAndNotEmpty:path size:&size])
        {
            [item setFilePathN:path];
        }
        else
        {
            [item setFilePathN:nil];
        }
    }
    else
    {
        [item setFilePathN:nil];
    }
    item.isCheckDownload = YES;
    return item.FileName && ((item.AudioRemoteUrl && item.AudioFileName) || (!item.AudioRemoteUrl));
}
+ (VDCItem *)getVDCItem:(MTV*)item Sample:(MTV *)sample
{
    VDCItem * localVDCItem = nil;
    NSString * remoteUrl = nil;
    NetworkStatus status = [[MTVUploader sharedMTVUploader]networkStatus];
    long userID = [[UserManager sharedUserManager]currentUser].UserID;
    
    BOOL isCompleted = NO;
    
    if(!item.isCheckDownload)
    {
        isCompleted = [WTVideoPlayerView isDownloadCompleted:&item Sample:sample NetStatus:status UserID:userID];
    }
    else
    {
        isCompleted = item.FileName && ((item.AudioRemoteUrl && item.AudioFileName) || (!item.AudioRemoteUrl));
    }
    
    //    NSString * path =
    [item getMTVUrlString:status userID:userID remoteUrl:&remoteUrl];
    
    if(isCompleted) //本地文件
    {
        VDCItem * localItem = [[VDCManager shareObject]getVDCItemByURL:remoteUrl checkFiles:NO];
        localItem.localFileName = item.FileName;// [[UDManager sharedUDManager]getFileName:item.FilePath];
        localItem.AudioFileName = item.AudioFileName;//[[UDManager sharedUDManager]getFileName:item.AudioPath];
        //        localItem.localFilePath = item.FilePath;
        localItem.remoteUrl = remoteUrl;
        localItem.contentLength = [[VDCManager shareObject]fileSizeForPath:[item getFilePathN]];
        localItem.downloadBytes = localItem.contentLength;
        localItem.AudioUrl = item.AudioRemoteUrl;
//        localItem.AudioPath = item.AudioPath;
        localItem.MTVID = item.MTVID;
        if(localItem.SampleID !=item.SampleID)
        {
            localItem.SampleID = item.SampleID;
            [[VDCManager shareObject] rememberDownloadUrl:localItem tempPath:localItem.tempFilePath];
        }
        localVDCItem = localItem;
        
    }
    else
    {
        VDCManager * vdcManager = [VDCManager shareObject];
        
        VDCItem * remoteItem  = [vdcManager getVDCItemByURL:remoteUrl checkFiles:NO];
        if(remoteItem)
        {
            remoteItem.MTVID = item.MTVID;
            if(item.FileName && item.FileName.length>0)
            {
                remoteItem.localFileName = item.FileName;// [[UDManager sharedUDManager]getFileName:item.FilePath];
                //                remoteItem.localFilePath = item.FilePath;
                remoteItem.remoteUrl = remoteUrl;
                remoteItem.contentLength = [[VDCManager shareObject]fileSizeForPath:[item getFilePathN]];
                remoteItem.downloadBytes = remoteItem.contentLength;
            }
            if(item.AudioFileName && item.AudioFileName.length>2)
            {
                remoteItem.AudioFileName = item.AudioFileName;// [[UDManager sharedUDManager]getFileName:item.AudioPath];
            }
            if(item.AudioRemoteUrl && item.AudioRemoteUrl.length>2)
            {
                remoteItem.AudioUrl = item.AudioRemoteUrl;
            }
            if(remoteItem.SampleID !=item.SampleID)
            {
                remoteItem.SampleID = item.SampleID;
                [[VDCManager shareObject] rememberDownloadUrl:remoteItem tempPath:remoteItem.tempFilePath];
            }
            localVDCItem = remoteItem;
        }
        
    }
    return localVDCItem;
}
+ (void)stopCacheMTV:(MTV *)item
{
    [[VDCManager shareObject] stopDownload:nil];
}
#pragma mark - play mtv
- (BOOL) playMTV:(MTV*)item{
    return YES;
}

@end
