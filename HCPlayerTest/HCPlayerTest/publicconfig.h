//
//  publicconfig.h
//  HCPlayerTest
//
//  Created by HUANGXUTAO on 16/5/4.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import <HCBaseSystem/config.h>

#ifndef publicconfig_h
#define publicconfig_h


#ifndef __OPTIMIZE__
#define USEDEBUGSERVER  //******
#define FULL_REQUEST
#define TrackWindowList //记录窗口历史,暂时不需要
#else
//    #define USEDEBUGSERVER  //******
#endif



#ifdef USEDEBUGSERVER
    #define CT_HOSTPORT         9000
    #define CT_HOSTIP           @"120.26.105.93"
    //    #define CT_HOSTIP           @"42.121.127.139"
    #define CT_HOSTNAME         @"testlogin.seenvoice.com"
    #define CT_INTERFACE        @"http://testlogin.seenvoice.com/service.ashx"
    #define CT_UPLOADSERVER     @"http://image.suixing.com:8088"
    #define CT_UPLOADSERVERPATH @"/Service.asmx/AjaxUpload"

    #define CT_IMAGESERVERPATH  DOMAIN_COVER_ROOT //@"http://7xjbp9.com2.z0.glb.qiniucdn.com"
    #define CT_IMAGEPATHROOT    DOMAIN_COVER_ROOT //@"http://7xjbp9.com2.z0.glb.qiniucdn.com"

    #define CT_IMAGEPATHROOTALTER @"http://image.suixing.com/upload/"
    #define CT_IMAGEPATHROOT2   @"qiniucdn.com"
#else
    #define CT_HOSTPORT         10008
    //    #define CT_HOSTIP           @"192.168.2.32"
    #define CT_HOSTIP           @"120.26.105.93"
    #define CT_HOSTNAME         @"login.seenvoice.com"
    #define CT_INTERFACE        @"http://login.seenvoice.com/service.ashx"
    #define CT_UPLOADSERVER     @"http://image.suixing.com"
    #define CT_UPLOADSERVERPATH @"/Service.asmx/AjaxUpload"

    #define CT_IMAGESERVERPATH  DOMAIN_COVER_ROOT //@"http://7xj5fp.com1.z0.glb.clouddn.com/"
    #define CT_IMAGEPATHROOT    DOMAIN_COVER_ROOT //@"http://7xj5fp.com1.z0.glb.clouddn.com/"
    #define CT_IMAGEPATHROOTALTER   @"http://image.seenvoice.com/"
    #define CT_IMAGEPATHROOT2       @"http://simages.b0.upaiyun.com/"   //后台有可能写入这样的地址，其实是指向iyp.suixing.com
#endif

#endif /* publicconfig_h */
