//
//  WTRecordTopPannel(Upload).h
//  maiba
//
//  Created by HUANGXUTAO on 16/4/2.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import "WTRecordTopPannel.h"

@interface WTRecordTopPannel(Upload)
- (BOOL)canShowProgress:(MTV *)item userID:(NSInteger)userID;

- (void)showUploadProgressWithUserID:(NSInteger)userID sampleID:(NSInteger)sampleID;
- (void)hideUploadProgress:(BOOL)animates;
- (void)removeUploadObserver;
- (void)beginUpload;
- (void)continueProgress;

@end
