//
//  CMD_GetSampleInfo.m
//  maiba
//
//  Created by WangSiyu on 15/12/31.
//  Copyright © 2015年 seenvoice.com. All rights reserved.
//

#import "CMD_GetSampleInfo.h"
#import "HCBase.h"
#import "DeviceConfig.h"
#import "HCCallResultForWT.h"
#import "HCDBHelper(WT).h"
#import "Samples.h"

@implementation CMD_GetSampleInfo

@synthesize sampleID;
@synthesize singUserID;
- (id)init
{
    if(self = [super init])
    {
        CMDID_ = 42;
        useHttpSender_ = YES;
        singUserID = 0;
    }
    return self;
}
- (BOOL)calcArgsAndCacheKey
{
    NSLog(@"A_5_11_0_42_获取用户的Sample列表");
    DeviceConfig * info = [DeviceConfig Instance];
    NSString * currentVersion = info.Version;
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                          //                          info.UDI,@"ClientID",
                          //#ifdef IS_MANAGERCONSOLE
                          //                          @([SystemConfiguration sharedSystemConfiguration].loginUserID),@"UserID",
                          //#else
                          @([self userID]),@"userid",
                          @(sampleID),@"sampleid",
                          @(singUserID),@"singuserid",
                          //#endif
                          @"5.11.0",@"scode",
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
    
    Samples * item = [Samples new];
    
    DBHelper * db = [DBHelper sharedDBHelper];
    
    NSString * sql = [NSString stringWithFormat:@"select * from samples where SampleID=%ld;",
                      sampleID];
    if([db open])
    {
        [db execWithEntity:item sql:sql];
        [db close];
    }
    
    if(item.SampleID>0)
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
        Samples * item = (Samples *)[self parseData:result];
        ret.Data = item;
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
    return [[Samples alloc] initWithDictionary:[result objectForKey:@"data"]];
}
@end
