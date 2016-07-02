//
//  FCOSessionModel.m
//  fco
//
//  Created by delmarz on 6/14/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOSessionModel.h"

@interface FCOSessionModel()
@end

@implementation FCOSessionModel

+ (FCOSessionModel *)sharedInstance {
    static FCOSessionModel *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[FCOSessionModel alloc] init];
    });
    
    return _sharedInstance;
}

- (void)setToken:(NSString *)token {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"token"];
    [defaults synchronize];
}

- (BOOL)isLoggedIn {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults valueForKey:@"token"];
    
    if (token == nil) {
        return NO;
    }
    
    return YES;
}

@end
