//
//  AVFunComm.m
//  Wutong
//
//  Created by HUANGXUTAO on 15/3/19.
//  Copyright (c) 2015年 HUANGXUTAO. All rights reserved.
//

#import "AVFunComm.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <hccoren/base.h>
#import "HCBase.h"

@implementation AVFunComm
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVURLAsset *asset = PP_AUTORELEASE([[AVURLAsset alloc] initWithURL:videoURL options:nil]);
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = PP_AUTORELEASE([[AVAssetImageGenerator alloc] initWithAsset:asset]);
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    
    if(thumbnailImageRef)
        CGImageRelease(thumbnailImageRef);
    
    return PP_AUTORELEASE(thumbnailImage);
}
+ (void) combinateAudio2Video:(NSURL *)audioUrl videoUrl:(NSURL *)videoUrl outputPath:(NSString *)outPath
{
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//
//    NSString *videoURL = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.mp4", ]];
//    NSURL *videoFileURL = [NSURL fileURLWithPath:videoURL];
//    NSString *audioURL = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.caf", _nameField.text]];
//    NSURL *audioFileURL = [NSURL fileURLWithPath:audioURL];
    
    
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audioUrl options:nil];
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoUrl options:nil];
    
    
    
    
    AVAssetTrack *assetVideoTrack = nil;
    AVAssetTrack *assetAudioTrack = nil;
    
    
    
    
    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:videoUrl]) {
//        NSArray *assetArray = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
//        if ([assetArray count] > 0)
//            assetVideoTrack = assetArray[0];
//    }
//    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:audioURL] && [prefs boolForKey:@"switch_audio"]) {
//        NSArray *assetArray = [audioAsset tracksWithMediaType:AVMediaTypeAudio];
//        if ([assetArray count] > 0)
//            assetAudioTrack = assetArray[0];
//    }
    
    //double degrees = 0.0;
    //if ([prefs objectForKey:@"video_orientation"])
    //  degrees = [[prefs objectForKey:@"video_orientation"] doubleValue];
    
    
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    if (assetVideoTrack != nil) {
        AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:assetVideoTrack atTime:kCMTimeZero error:nil];
        if (assetAudioTrack != nil) [compositionVideoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) toDuration:audioAsset.duration];
        //[compositionVideoTrack setPreferredTransform:CGAffineTransformMakeRotation(degreesToRadians(degrees))];
    }
    
    if (assetAudioTrack != nil) {
        AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:assetAudioTrack atTime:kCMTimeZero error:nil];
    }
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                          presetName:AVAssetExportPresetPassthrough];
    
    
    NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.mov", outPath]];
    NSURL *savetUrl = [NSURL fileURLWithPath:savePath];
    
    _assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    _assetExport.outputURL = savetUrl;
    _assetExport.shouldOptimizeForNetworkUse = NO;
    
    
    //[_startStopButton setTitle:@"Merging... Please Wait..." forState:UIControlStateNormal];
    //_startStopButton.userInteractionEnabled = NO;
    
    
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:^(void){
        
        switch(_assetExport.status)
        {
            case AVAssetExportSessionStatusCompleted:
            {
                
                //statusText.text = @"Export Completed";
                //[_startStopButton setTitle:@"Start Recording" forState:UIControlStateNormal];
//                _nameField.userInteractionEnabled = YES;
//                //_startStopButton.userInteractionEnabled = YES;
//                
//                NSString *videoToDelete = _nameField.text;
//                NSString *audioToDeletePath = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
//                                                stringByAppendingPathComponent:videoToDelete]
//                                               stringByAppendingPathExtension:@"caf"];
//                NSString *videoToDeleteTwo = [NSString stringWithFormat:@"%@", _nameField.text];
//                NSString *videoToDeletePath = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
//                                                stringByAppendingPathComponent:videoToDeleteTwo]
//                                               stringByAppendingPathExtension:@"mp4"];
//                [[[NSFileManager alloc]init]removeItemAtPath:audioToDeletePath error:NULL];
//                [[[NSFileManager alloc]init]removeItemAtPath:videoToDeletePath error:NULL];
                
            }
                break;
                
            case AVAssetExportSessionStatusWaiting:
            {
                //statusText.text = @"Waiting...";
                //[_startStopButton setTitle:@"Waiting..." forState:UIControlStateNormal];
            }
                break;
            case AVAssetExportSessionStatusExporting:
            {
                //statusText.text = @"Exporting...";
                //[_startStopButton setTitle:@"Exporting..." forState:UIControlStateNormal];
            }
                break;
                
            case AVAssetExportSessionStatusFailed:
            {
                //statusText.text = @"FAILED. Trying again...";
                //[_startStopButton setTitle:@"FAILED. Trying again..." forState:UIControlStateNormal];
                //[self mergeAudio];
                
            }
                break;
            case AVAssetExportSessionStatusCancelled:
            {
                
            }
                break;
            case AVAssetExportSessionStatusUnknown:
            {
                
            }
                break;
        }
    }
        ];
    
    PP_RELEASE(_assetExport);
    PP_RELEASE(audioAsset);
    PP_RELEASE(videoAsset);
//    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audioUrl options:nil];
//    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoUrl options:nil];
//    
//    AVMutableComposition* mixComposition = [AVMutableComposition composition];
//    
//    AVMutableCompositionTrack *compositionCommentaryTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
//                                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
//    [compositionCommentaryTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
//                                        ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
//                                         atTime:kCMTimeZero error:nil];
//    
//    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
//                                                                                   preferredTrackID:kCMPersistentTrackID_Invalid];
//    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
//                                   ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
//                                    atTime:kCMTimeZero error:nil];
//    
//    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
//                                                                          presetName:AVAssetExportPresetPassthrough];
//    
//    NSString* videoName = outPath;// @"export.mov";
//    
//    NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoName];
//    NSURL    *exportUrl = [NSURL fileURLWithPath:exportPath];
//    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
//    {
//        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
//    }
//    
//    _assetExport.outputFileType = @"com.apple.quicktime-movie";
//    
//    DLog(@"file type %@",_assetExport.outputFileType);
//    
//    _assetExport.outputURL = exportUrl;
//    _assetExport.shouldOptimizeForNetworkUse = YES;
//    
//    [_assetExport exportAsynchronouslyWithCompletionHandler:^(void){
//        //when done
//        
//        // 下面是把视频存到本地相册里面，存储完后弹出对话框。
//
////        [_assetLibrarywriteVideoAtPathToSavedPhotosAlbum:[NSURLURLWithString:exportPath]
////                                         completionBlock:^(NSURL *assetURL, NSError *error1) {
////                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"好的!" message: @"整合并保存成功！"
////                                                           delegate:nil
////                                                  cancelButtonTitle:@"OK"
////                                                  otherButtonTitles:nil];
////                                                [alert show];
////                                         }];
//    }];
}
@end
