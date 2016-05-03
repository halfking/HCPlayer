
//
//  lyricCell.m
//  HDMusicPlayer
//
//  Created by Hidy on 15/7/5.
//  Copyright (c) 2015年 Hidy. All rights reserved.
//

#import "LyricCell.h"

@interface LyricCell ()

@end

@implementation LyricCell

+ (LyricCell *)initWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"lrcCell";
    [tableView registerClass:[LyricCell class] forCellReuseIdentifier:cellIdentifier];
    LyricCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.lrc = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 30)];
        self.lrc.textAlignment = NSTextAlignmentCenter;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.lrc];
    }
    return self;
}








- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
