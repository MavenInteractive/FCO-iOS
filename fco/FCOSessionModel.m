//
//  FCOSessionModel.m
//  fco
//
//  Created by delmarz on 6/14/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOSessionModel.h"
#import "FCOHTTPClient.h"

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

- (NSString *)token {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"token"];
}

- (BOOL)isLoggedIn {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults valueForKey:@"token"];
    if (token == nil) {
        return NO;
    }
    return YES;
}

- (FCOUserModel *)activeUser {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:@"activeUser"];
    FCOUserModel *loggedInUser = (FCOUserModel *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return loggedInUser;
}

- (void)setActiveUser:(FCOUserModel *)activeUser {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:activeUser];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:@"activeUser"];
    [defaults synchronize];
}

- (FCOCalloutModel *)activeCallout {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodeObject = [defaults objectForKey:@"activeCallout"];
    FCOCalloutModel *loggedInUser = (FCOCalloutModel *)[NSKeyedUnarchiver unarchiveObjectWithData:encodeObject];
    return loggedInUser;
}

- (void)setActiveCallout:(FCOCalloutModel *)activeCallout {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:activeCallout];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:@"activeCallout"];
    [defaults synchronize];
}


@end
