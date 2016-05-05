//
//  WTRecordTopPannel(Upload).m
//  maiba
//
//  Created by HUANGXUTAO on 16/4/2.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import "WTRecordTopPannel(Upload).h"
#import <hccoren/base.h>
#import <hccoren/JSON.h>
#import <HCBaseSystem/User_WT.h>
#import <HCMVManager/MTVUploader.h>
#import <HCMVManager/CMD_GetUserMTVBySample.h>
#import <HCBaseSystem/UpDown.h>
#import <hccoren/UIView+extension.h>
#import <HCBaseSystem/cmd_wt.h>
#import "player_config.h"


@implementation WTRecordTopPannel(Upload)
- (void)buildUploadingProgressView
{
    if(!progressView_)
    {
        progressView_ = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 85)/2.0f, (self.frame.size.height - 30)/2.0f, 85, 30)];
        
        uploadIcon_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        uploadIcon_.image = [UIImage imageNamed:@"HCPlayer.bundle/upload"];
        [progressView_ addSubview:uploadIcon_];
        
        uploadProgressLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(35, 10, 50, 10)];
        uploadProgressLabel_.text = @"上传";
        uploadProgressLabel_.font = [UIFont systemFontOfSize:12];
        uploadProgressLabel_.textColor = [UIColor whiteColor];
        uploadProgressLabel_.shadowOffset = SHADOW_SIZE;
        uploadProgressLabel_.shadowColor = COLOR_SHADOW;
        [progressView_ addSubview:uploadProgressLabel_];
        
        UITapGestureRecognizer *uploadGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeUploadProgressState:)];
        [progressView_ addGestureRecognizer:uploadGesture];
        
        [self addUploadingObserver];
        progressView_.alpha = 0;
        [self addSubview:progressView_];
    }
    else
    {
        progressView_.frame = CGRectMake((self.frame.size.width - 85)/2.0f, 10, 85, 30);
    }
//    [self bringNonewowrkNoEarTop];
}
- (void)changeUploadProgressState:(id)sender
{
    if (self.isUploadingSuspended)
    {
        [self continueProgress];
    }
    else
    {
        [self suspendProgress];
    }
}

- (void)suspendProgress{
    NSLog(@"暂停进度");
    self.isUploadingSuspended = YES;
    
    [[MTVUploader sharedMTVUploader]stopUploadMtv:self.MTVItem];
    
    uoploadNeedShow_ = YES;
    
    [self showUploadingProgressViewAutoInThread];
    
    uploadIcon_.image = [UIImage imageNamed:@"HCPlayer.bundle/upload"];
    uploadProgressLabel_.textColor = [UIColor whiteColor];
}

- (void)continueProgress
{
    if ([self readyToUpload:nil])
    {
        NSLog(@"进度继续");
        self.isUploadingSuspended = NO;
        [self showUploadingProgressViewAutoInThread];
        uploadIcon_.image = [UIImage imageNamed:@"HCPlayer.bundle/upload_yellow"];
        uploadProgressLabel_.textColor = COLOR_BA;
    }
}

- (void)showUploadProgressWithUserID:(NSInteger)userID sampleID:(NSInteger)sampleID
{
    NSLog(@"showUploadProgress ---> UserID:%d,sample:%d",(int)userID,(int)sampleID);
    if (sampleID < 0) {
        [self hideUploadProgress:NO];
        return;
    }
    
    if (!progressView_) {
        [self buildUploadingProgressView];
    }
    uoploadNeedShow_ = YES;
    //    if(self.progressView.hidden)
    //    {
    //    [self addUploadingObserver];
    //    }
    
    progressView_.hidden = YES;
    
    MTV * item  = self.MTVItem;
//    if((item.MTVID!=0 &&item.FilePath && item.FilePath.length>0)) //因为还是本地的文件，所以不能到网上查
//    {
//        mtvItem_ = item;
//    }
    //没有Item时，不需要显示
    if(!item) return;
    //如果用户文件已经上传完成或者还没有文件，则不需要显示
    if(item.UserID == userID && item.SampleID == sampleID)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           if(![self canShowProgress:item userID:userID]) return;
                           
                           //检测当前文件上传的状态
                           BOOL isUPloading = [[MTVUploader sharedMTVUploader] isUploading:item];
                           
                           self.isUploadingSuspended = !isUPloading;
                           if(self.isUploadingSuspended)
                           {
                               [self suspendProgress];
                           }
                           else
                           {
                               [self continueProgress];
                               
                           }
                           [self showUploadingProgressViewAutoInThread];
                       });
        
    }
    else
    {
        [self loadDataWithUserID:userID sampleID:sampleID];
    }
    
}

#pragma mark - show hide auto

- (void)showUploadingProgressViewAutoInThread
{
    NSLog(@"在主线程中显示上传进度 －－－ %d",[NSThread isMainThread]);
    if ([NSThread isMainThread])
    {
        [self showUploadingProgressViewAuto];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [self showUploadingProgressViewAuto];
                       });
    }
}

- (void)showUploadingProgressViewAuto
{
    if(!progressView_ || (!uoploadNeedShow_)) return;
    uoploadNeedShow_ = NO;
    if(progressView_.hidden==NO) return;
    progressView_.alpha = 0;
    progressView_.hidden = NO;
    //    [self addUploadingObserver];
    UDInfo * info = [[MTVUploader sharedMTVUploader]getUploadInfo:self.MTVItem];
    NSLog(@"上传进度 %.1f",info.Percent);
    if(![[UserManager sharedUserManager]isLogin] || !info || info.Percent<0 || info.Percent>1)
    {
        [self suspendProgress];
        uploadProgressLabel_.text = @"上传";
    }
    else
    {
        //        [self suspendProgress];
        if (info.Percent == 1) {
            uploadProgressLabel_.text = @"上传";
        } else {
            uploadProgressLabel_.text = [NSString stringWithFormat:@"%d%%",(int)(info.Percent*100)];
        }
    }
    [self bringSubviewToFront:progressView_];
    if(progressView_.alpha!=1)
    {
        [UIView animateWithDuration:0.3 animations:^(void)
         {
             progressView_.alpha = 1;
             
         } completion:^(BOOL finished)
         {
             uoploadNeedShow_ = YES;
         }];
    }
    else
    {
        uoploadNeedShow_ = YES;
    }
    
}

- (void)autoHideUploadProgress:(NSTimer *)timer
{
    if(progressView_ && uoploadNeedShow_) return;
    
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       [self hideUploadProgress:YES];
                       
                   });
    
    if(uploadProgressHideTimer_)
    {
        [uploadProgressHideTimer_ invalidate];
        PP_RELEASE(uploadProgressHideTimer_);
    }
}

- (void)hideUploadProgress:(BOOL)animates
{
    if(progressView_.hidden) return;
    //    [self removeUploadObserver];
    
    if(!animates)
    {
        progressView_.hidden = YES;
        progressView_.alpha = 0;
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^(void)
         {
             progressView_.alpha = 0;
         } completion:^(BOOL finished)
         {
             progressView_.hidden = YES;
         }];
    }
    //    self.progressView.needShow = NO;
}
- (BOOL)canShowProgress:(MTV *)item userID:(NSInteger)userID
{
    NSLog(@"downloadUrl ---> %@",item.DownloadUrl);
    if(item.MTVID==0 ||item.UserID==0) return NO;
    if(item.UserID!=userID) return NO;
    if(item.FileName && item.FileName.length>0)
    {
        if(![[UDManager sharedUDManager]existFileAtPath:[item getFilePathN]])
        {
            return NO;
        }
    }
    else
        return NO;
//    if([self bringNonewowrkNoEarTop])
//        return NO;
    
    return ![[MTVUploader sharedMTVUploader]isMtvUploaded:item];
}
#pragma mark - 监听事件

- (void)uploadCompleted:(NSNotification *)notification
{
    UDInfo * item = notification.object;
    
    NSLog(@"uploadCompleted %@",item);
    NSString * mtvKey = [self.MTVItem getKey];
    NSString * audioKey = [self.MTVItem getAudioKey];
    //    NSString * key = mtvKey && mtvKey.length>0?mtvKey:audioKey;
    
    //应该是声音文件先上传完吧
    if(item && audioKey && [item.Key isEqualToString:audioKey])
    {
        self.MTVItem.AudioRemoteUrl = item.RemoteUrl;
    }
    else if(item && [item.Key isEqualToString:mtvKey])
    {
        //        if(mtvKey && mtvKey.length>0)
        self.MTVItem.DownloadUrl = item.RemoteUrl;
        //        else
        //            mtvItem_.AudioRemoteUrl = item.RemoteUrl;
        if(self.delegate && [self.delegate respondsToSelector:@selector(recordPannel:uploadCompleted:)])
        {
            [self.delegate recordPannel:self uploadCompleted:self.MTVItem];
        }
    }
}
- (void)uploadStatusChanged:(NSNotification *)notification
{
    UDInfo * item = notification.object;
    NSLog(@"uploadStatusChanged 暂停0 开始1 ---> %d",item.Status);
    
    if(!item || !item.Key) return;
    
    NSString * mtvKey = [self.MTVItem getKey];
    
    if(item &&
       ([item.Key isEqualToString:mtvKey]))
    {
        //非正常状态时
        if(item.Status==2 || item.Status>9)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:NT_MSGNOTICE object:item.ErrorInfo userInfo:[NSDictionary dictionaryWithObjectsAndKeys:item.ErrorInfo,@"message", nil]];
        }
    }
}
- (void)uploadProgressChanged:(NSNotification *)notification
{
    UDInfo * item = notification.object;
    NSLog(@"uploadProgressChanged %@",item);
    
    
    
    NSString * mtvKey = [self.MTVItem getKey];
    NSString * audioKey = [self.MTVItem getAudioKey];
    NSString * key = mtvKey && mtvKey.length>0?mtvKey:audioKey;
    
    NSLog(@"%@ --- %@ audioKey:%@",item.Key,mtvKey,audioKey?audioKey:@"nil");
    
    
    if(item &&
       ([item.Key isEqualToString:key] ))
    {
        NSLog(@"**show progress:%f",item.Percent);
        CGFloat percent = item.Percent;
        if(percent <= 1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showUploadingProgressViewAuto];
                
                if(!self.isUploadingSuspended && progressView_.hidden==NO)
                {
                    NSLog(@"self.progressView.hidden %d",progressView_.hidden);
                    //                    [self.progressView setProgress:percent];
                    uploadProgressLabel_.text = [NSString stringWithFormat:@"%d%%",(int)(percent*100)];
                    uploadIcon_.image = [UIImage imageNamed:@"HCPlayer.bundle/upload_yellow"];
                    uploadProgressLabel_.textColor = COLOR_BA;
                }
                else
                {
                    NSLog(@"has upload progress.but isuploadingsuspend:%d",self.isUploadingSuspended);
                }
            });
        }
    }
}
- (void)addUploadingObserver
{
    NSLog(@"addUploadingObserver");
    [self removeUploadObserver];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(uploadStatusChanged:) name:NT_UPLOADSTATECHANGED object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(uploadProgressChanged:) name:NT_UPLOADPROGRESSCHANGED object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(uploadCompleted:) name:NT_UPLOADCOMPLETED object:nil];
    
}

- (void)removeUploadObserver
{
    NSLog(@"removeUploadObserver");
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NT_UPLOADSTATECHANGED object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NT_UPLOADPROGRESSCHANGED object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NT_UPLOADCOMPLETED object:nil];
}



- (void)loadDataWithUserID:(NSInteger)userID sampleID:(NSInteger)sampleID
{
    if (isUploadMtvQuering_) {
        return;
    }
    isUploadMtvQuering_ = YES;
    
    CMD_CREATE(cmd, GetUserMTVBySample, @"GetUserMTVBySample");
    
    cmd.userID = userID;
    cmd.sampleID = sampleID;
    
    cmd.CMDCallBack= ^(HCCallbackResult * result)
    {
        isUploadMtvQuering_ = NO;
        
        if(result.Code == 0 && result.Data)
        {
            
            MTV * item = (MTV*)result.Data;
            if (item && item.MTVID!=0)
            {
                NSLog(@"有唱过的mtv");
                uoploadNeedShow_ = YES;
                
                if([self canShowProgress:item userID:userID])
                {
                    if(![[MTVUploader sharedMTVUploader]isMtvUploaded:item])
                    {
                        [self showUploadingProgressViewAutoInThread];
                    }
                }
                else
                {
                    //no show
                }
            }
        }
        else
        {
            NSLog(@"get mtv user singed failure:%@",result.Msg);
        }
        
    };
    [cmd sendCMD];
}

//- (CGFloat)getFileSize
//{
//    if (mtvItem_ && mtvItem_.FilePath) {
//        NSString *filePath = mtvItem_.FilePath;
//        if ([filePath hasPrefix:@"file://"]) {
//            filePath = [filePath substringFromIndex:7];
//        }
//        CGFloat fileSize = [[VDCManager shareObject]fileSizeForPath:filePath] / (1024*1024.0f);
//        if(fileSize<=0) fileSize = 10;
//        return  fileSize;
//    }
//    else
//    {
//        return 10;
//    }
//    
//}
#pragma mark - mtvupload delegate
#pragma mark - get cover and move file
- (BOOL)readyToUpload:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(recordPannel:beginUpload:)])
    {
        if([self.delegate recordPannel:self beginUpload:self.MTVItem])
        {
            [self beginUpload];
            return YES;
        }
    }
    return NO;
//    loginFlag_ = 2;
//    if ([self checkLoginStatus]) {
//        [self beginUpload];
//        return YES;
//    }
//    else return NO;
//    
}

- (void)beginUpload
{
    if (self.isUploadingSuspended) {
        self.isUploadingSuspended = NO;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(recordPannel:beginUpload:)])
    {
        if(![self.delegate recordPannel:self beginUpload:self.MTVItem])
        {
            return ;
        }
    }

    MTV * item = self.MTVItem;
    NSLog(@"begin update:%@",[self.MTVItem JSONRepresentationEx]);
    BOOL ret = NO;
    if(item.MTVID <0 || !item.CoverUrl || [HCFileManager isLocalFile:item.CoverUrl])
    {
        if(item.UserID!=[UserManager sharedUserManager].userID)
        {
            item.UserID = [UserManager sharedUserManager].userID;
        }
        
        ret = [[MTVUploader sharedMTVUploader]uploadMTVInfo:item materias:nil forceUpload:YES delegate:self];
        if(!ret)
        {
            NSLog(@"upload mtv info failure.....");
            SNAlertView * alterView = [[SNAlertView alloc]initWithTitle:MSG_ERROR message:MSG_SAVEFAILURE
                                                               delegate:self
                                                      cancelButtonTitle:EDIT_IKNOWN otherButtonTitles:EDIT_RETRY, nil];
            alterView.tag = 4005;
            UIViewController * vc = [self traverseResponderChainForUIViewController];
            [alterView show:vc.view];
            return;
        }
    }
    else if(item.MTVID==0)
    {
        SNAlertView * alterView = [[SNAlertView alloc]initWithTitle:MSG_ERROR message:@"伴奏不能上传，请检查。" delegate:self cancelButtonTitle:EDIT_IKNOWN otherButtonTitles:nil, nil];
        UIViewController * vc = [self traverseResponderChainForUIViewController];
        [alterView show:vc.view];
    }
    else
    {
        //        mtvItem_.UserID = [UserManager sharedUserManager].userID;
        //        [[MTVUploader sharedMTVUploader]updateMTVKeyAndUserID:mtvItem_];
        ret = [[MTVUploader sharedMTVUploader]uploadMTV:item];
    }
    
}

- (void)MTVUploader:(MTVUploader *)uploader didMTVSaveLocalDB:(MTV *)item
{
    NSLog(@"save to local db OK:%li",item.MTVID);
}
- (BOOL)MTVUploader:(MTVUploader *)uploader didMTVInfoCompleted:(MTV *)item
{
    if(self.MTVItem!=item)
    {
        self.MTVItem.MTVID = item.MTVID;
    }
    NSLog(@"save mtv[%li] ok:%@  cover:%@",item.MTVID, item.FileName,item.CoverUrl);
    
    return YES; //返回YES，表示需要上传文件
    
}
- (void)MTVUploader:(MTVUploader *)uploader didMtvInfoFailuer:(MTV *)item error:(NSString *)error
{
    NSLog(@" save mtv:%@ failure:%@",item.FileName,error);
    SNAlertView * alterView = [[SNAlertView alloc]initWithTitle:@"保存视频信息失败." message:error delegate:nil cancelButtonTitle:EDIT_ABANDONVIDEO otherButtonTitles:EDIT_RETRY,nil];
    alterView.tag = 4002;
    UIViewController * vc = [self traverseResponderChainForUIViewController];
    [alterView show:vc.view];
    PP_RELEASE(alterView);
}

@end
