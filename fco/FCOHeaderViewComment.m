//
//  FCOHeaderViewComment.m
//  fco
//
//  Created by Kryptonite on 7/28/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOHeaderViewComment.h"

@implementation FCOHeaderViewComment

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



- (IBAction)buttonPressed:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(buttonPressed:btnPressed:)]) {
        [_delegate buttonPressed:self btnPressed:_button];
    }
}


@end
