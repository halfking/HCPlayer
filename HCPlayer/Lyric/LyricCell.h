//
//  lyricCell.h
//  HDMusicPlayer
//
//  Created by Hidy on 15/7/5.
//  Copyright (c) 2015年 Hidy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LyricView;

@interface LyricCell : UITableViewCell

@property (nonatomic, strong) UILabel *lrc;

+ (LyricCell *)initWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end
