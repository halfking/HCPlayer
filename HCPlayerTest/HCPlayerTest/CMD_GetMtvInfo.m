//
//  CMD_GetMtvInfo.m
//  Wutong
//
//  Created by HUANGXUTAO on 15/5/30.
//  Copyright (c) 2015年 HUANGXUTAO. All rights reserved.
//

#import "CMD_GetMtvInfo.h"
#import "HCBase.h"
#import "DeviceConfig.h"
#import "HCCallResultForWT.h"
#import "MTV.h"
#import "HCDBHelper(WT).h"
#import "Samples.h"

@implementation CMD_GetMtvInfo
@synthesize MtvID,IncludeSummary;
@synthesize HasSample;

- (id)init
{
    if(self = [super init])
    {
        CMDID_ = 42;
        useHttpSender_ = YES;
    }
    return self;
}
- (BOOL)calcArgsAndCacheKey
{
    NSLog(@"A_2_15_0_42_获取用户的MTV列表");
    DeviceConfig * info = [DeviceConfig Instance];
    NSString * currentVersion = info.Version;
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                          //                          info.UDI,@"ClientID",
                          //#ifdef IS_MANAGERCONSOLE
                          //                          @([SystemConfiguration sharedSystemConfiguration].loginUserID),@"UserID",
                          //#else
                          @([self userID]),@"userid",
                          @(MtvID),@"mtvid",
                          @(HasSample?1:0),@"hassample",
                          //#endif
                          @"2.15.0",@"scode",
                          currentVersion,@"ver",    //当前APP版本号
                          info.IPAddress,@"ip",
                          nil];
    if(args_) PP_RELEASE(args_);
    args_ = PP_RETAIN([dic JSONRepresentationEx]);
    if(argsDic_) PP_RELEASE(argsDic_);
    argsDic_ = PP_RETAIN(dic);
    return YES;
    
}
#pragma mark - query from db
//取原来存在数据库中的数据，当需要快速响应或者网络不通时
- (NSObject *) queryDataFromDB:(NSDictionary *)params
{
    MTV * item = [MTV new];
    
    DBHelper * db = [DBHelper sharedDBHelper];
    
    NSString * sql = [NSString stringWithFormat:@"select * from mtvs where mtvid=%ld  ;",
                      MtvID];
    if([db open])
    {
        [db execWithEntity:item sql:sql];
        [db close];
    }
    
    if(item.MTVID>0)
        return PP_AUTORELEASE(item);
    else
        PP_RELEASE(item);
    return nil;
    
}
#pragma mark - parse
- (HCCallbackResult *) parseResult:(NSDictionary *)result
{
    //
    //需要在子类中处理这一部分内容
    //
    HCCallResultForWT * ret = [[HCCallResultForWT alloc]initWithArgs:argsDic_?argsDic_ : [self.args JSONValueEx]
                                                            response:result];
    ret.DicNotParsed = result;
    
    if(ret.Code ==0)
    {
        MTV * item = (MTV *)[self parseData:result];
        ret.Data = item;
        
        NSDictionary * sampleDic = nil;
        if([ret.DicNotParsed objectForKey:@"sample"])
        {
            sampleDic = [ret.DicNotParsed objectForKey:@"sample"];
        }
        else if([ret.DicNotParsed objectForKey:@"Sample"])
        {
            sampleDic = [ret.DicNotParsed objectForKey:@"Sample"];
        }
        if(sampleDic)
        {
            Samples * item = [[Samples alloc]initWithDictionary:sampleDic];
            ret.SecondsItem = item;
            if(item && item.SampleID>0)
            {
                [[DBHelper sharedDBHelper]insertData:item needOpenDB:YES forceUpdate:YES];
            }
        }
        if(ret.Data && ret.IsFromDB ==NO)
        {
//            for (MTV * item in ret.List) {
//                if(!item.DateCreated||item.DateCreated.length==0)
//                {
//                    item.DateCreated = [CommonUtil stringFromDate:[NSDate date]];
//                }
//            }
//            [[DBHelper sharedDBHelper]insertDataArray:ret.List forceUpdate:YES];
            [[DBHelper sharedDBHelper]insertData:item needOpenDB:YES forceUpdate:YES];
        }
    }
    
    
    
    return PP_AUTORELEASE(ret);
}

- (NSObject*)parseData:(NSDictionary *)result
{
    return [self parseMtv:[result objectForKey:@"data"]];
}
- (MTV *)parseMtv:(NSDictionary *)dic
{
    MTV * item = [[MTV alloc]initWithDictionary:dic];
    //summary
//    "WorkCollections": {
//        "MTVID": 1,
//        "PlayCount": 0,
//        "LikeCount": 0,
//        "FavCount": 0,
//        "ShareCount": 0
//    },
    NSDictionary * summary = nil;
    if([dic objectForKey:@"WorkCollections"])
    {
        summary = [dic objectForKey:@"WorkCollections"];
        if([summary objectForKey:@"PlayCount"])
        {
            item.PlayCount = [[summary objectForKey:@"PlayCount"]intValue];
        }
        if([summary objectForKey:@"LikeCount"])
        {
            item.LikeCount = [[summary objectForKey:@"LikeCount"]intValue];
        }
        if([summary objectForKey:@"FavCount"])
        {
            item.FavCount = [[summary objectForKey:@"FavCount"]intValue];
        }
        if([summary objectForKey:@"ShareCount"])
        {
            item.ShareCount = [[summary objectForKey:@"ShareCount"]intValue];
        }
    }
    else if([dic objectForKey:@"workcollections"])
    {
        summary = [dic objectForKey:@"WorkCollections"];
        if([summary objectForKey:@"PlayCount"])
        {
            item.PlayCount = [[summary objectForKey:@"playcount"]intValue];
        }
        if([summary objectForKey:@"LikeCount"])
        {
            item.LikeCount = [[summary objectForKey:@"likecount"]intValue];
        }
        if([summary objectForKey:@"FavCount"])
        {
            item.FavCount = [[summary objectForKey:@"favcount"]intValue];
        }
        if([summary objectForKey:@"ShareCount"])
        {
            item.ShareCount = [[summary objectForKey:@"sharecount"]intValue];
        }
    }
//    if(summary)
//    {
//        if([summary objectForKey:@"PlayCount"])
//        {
//            item.PlayCount = [[summary objectForKey:@"PlayCount"]intValue];
//        }
//        if([summary objectForKey:@"LikeCount"])
//        {
//            item.LikeCount = [[summary objectForKey:@"LikeCount"]intValue];
//        }
//        if([summary objectForKey:@"FavCount"])
//        {
//            item.FavCount = [[summary objectForKey:@"FavCount"]intValue];
//        }
//        if([summary objectForKey:@"ShareCount"])
//        {
//            item.ShareCount = [[summary objectForKey:@"ShareCount"]intValue];
//        }
//    }
    return item;
}
@end
