//
//  TableViewCell.m
//  tabview
//
//  Created by zfu on 6/19/16.
//  Copyright © 2016 zfu. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell
@synthesize title;
@synthesize description;
@synthesize image;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
