//
//  FCOLoadingView.m
//  fco
//
//  Created by kryptonite on 6/5/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOLoadingView.h"

@implementation FCOLoadingView


- (id)init{//WithFrame:(CGRect)frame{
    self = [super init];//WithFrame:frame];
    if (self) {
        [self doInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self doInit];
    }
    return self;
}


- (void)doInit{
    [super doInit];
    [self setFrame:CGRectMake(0, 0, 30, 30)];
    [self setDuration:0.6];
    
    NSMutableArray *images = [NSMutableArray array];
    for (int i = 0; i <= 4; i++) {
        NSString *imgName = [NSString stringWithFormat:@"loader_0%d.png", i+1];
        [images addObject:[UIImage imageNamed:imgName]];
    }
    [self setImages:images];
}


@end
