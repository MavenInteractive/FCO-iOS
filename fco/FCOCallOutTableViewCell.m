//
//  FCOCallOutTableViewCell.m
//  fco
//
//  Created by Kryptonite on 6/9/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOCallOutTableViewCell.h"


@interface FCOCallOutTableViewCell () 

@end


@implementation FCOCallOutTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
       
    }
    return self;
}

//- (IBAction)viewDetailsPressed:(UIButton *)sender {
//    if (delegate && [delegate respondsToSelector:@selector(customCell:btnPressed:)]) {
//        [delegate customCell:self btnPressed:self.viewDetails];
//    }
//}

@end
