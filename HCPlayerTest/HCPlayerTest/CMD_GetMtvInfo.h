//
//  CMD_GetMtvInfo.h
//  Wutong
//
//  Created by HUANGXUTAO on 15/5/30.
//  Copyright (c) 2015年 HUANGXUTAO. All rights reserved.
//

#import "CMDOP_WT.h"

@interface CMD_GetMtvInfo : CMDOP_WT
@property (nonatomic,assign) long MtvID;
@property (nonatomic,assign) BOOL HasSample;
@property (nonatomic,assign) BOOL IncludeSummary;
@end
