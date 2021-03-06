//
//  player_config.h
//  HCPlayer
//
//  Created by HUANGXUTAO on 16/5/3.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#ifndef player_config_h
#define player_config_h

#define COLOR_O         UIColorFromRGB(0xe2e2e2) //main duration color
#define COLOR_Q         UIColorFromRGB(0x272727)
//麦爸新色卡
#define COLOR_BA        UIColorFromRGB(0xffc702)//黄色
#define COLOR_BB        UIColorFromRGB(0x858585)//灰色。
//#define COLOR_BC        UIColorFromRGB(0x24afff)//进度条蓝色
//#define COLOR_BD        UIColorFromRGB(0xff3817)//蓝
#define COLOR_BE        UIColorFromRGB(0x4f4f4f)//深灰
#define COLOR_BF        UIColorFromRGB(0xaaaaaa)//浅灰。
//#define COLOR_BH        UIColorFromRGB(0xa7a7a7)//灰色
//#define COLOR_BI        UIColorFromRGB(0x141414)//背景黑色
//#define COLOR_BJ        UIColorFromRGB(0xa8a8a8)//灰字
//#define COLOR_BL        UIColorFromRGB(0xe0e0e0)//字体白色
//#define COLOR_BM        UIColorFromRGB(0xff541c)//排行榜背景红色
//#define COLOR_BN        UIColorFromRGB(0xffdd38)//排行榜背景浅黄
#define COLOR_BO        UIColorFromRGB(0xff0202)//红色
//#define COLOR_BP        UIColorFromRGB(0x1b1b1b)//黑 字

//麦爸竖版新色卡
#define COLOR_CA        UIColorFromRGB(0xededed)//黑0.1 字
#define COLOR_CB        UIColorFromRGB(0xd6d6d6)//黑0.3 字
#define COLOR_CC        UIColorFromRGB(0xb8b8b8)//黑0.4 字
#define COLOR_CD        UIColorFromRGB(0xa3a3a3)//黑0.5 字
#define COLOR_CE        UIColorFromRGB(0x8d8d8d)//黑0.6 字
#define COLOR_CF        UIColorFromRGB(0x555555)//黑0.8 字
#define COLOR_CG        UIColorFromRGB(0x1a1a1a)//黑0.9 字
#define COLOR_CH        UIColorFromRGB(0x297ed5)//蓝
#define COLOR_CI        UIColorFromRGB(0xff6000)//橙
#define COLOR_CJ        UIColorFromRGB(0xff3e4d)//红
//#define COLOR_CK        UIColorFromRGB(0xffc702)//COLOR_BA 麦爸黄
#define COLOR_CL        UIColorFromRGB(0x2a2a2a)//黑

#define COLOR_SHADOW    COLOR_BF
#define SHADOW_SIZE     CGSizeMake(0, 0.5)

#define FONT_TITLESOFSIZE(xx)   [UIFont fontWithName:@"FZQingKeBenYueSongS-R-GB" size:xx]
#define FONT_STANDARD(xx)       [UIFont systemFontOfSize:xx]
#define FONT_STANDARD_BOLD(xx)  [UIFont boldSystemFontOfSize:xx]

#define MSG_PROMPT          @"提示"
#define NT_CACHEPROGRESS    @"NT_CACHEPROGRESS"

#endif /* player_config_h */
