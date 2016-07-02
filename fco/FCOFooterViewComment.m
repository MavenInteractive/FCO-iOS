//
//  FCOFooterViewComment.m
//  fco
//
//  Created by Kryptonite on 7/28/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOFooterViewComment.h"

@implementation FCOFooterViewComment

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)smileyButtonPressed:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(smileyButtonPressed:button:)]) {
        [_delegate smileyButtonPressed:self button:_smileyButton];
    }
}
@end
