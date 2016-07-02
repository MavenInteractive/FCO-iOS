//
//  FCOHTTPClient.m
//  fco
//
//  Created by delmarz on 6/14/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOHTTPClient.h"
#import "FCOSessionModel.h"


static NSString *const BASE_URL_STRING = @"http://api.fightcallout.com/api/v1.0/";

@implementation FCOHTTPClient

+ (FCOHTTPClient *)sharedInstance {
    static FCOHTTPClient *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[FCOHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL_STRING]];
    });

    FCOSessionModel *sesion = [FCOSessionModel sharedInstance];
    NSLog(@"Authorization Field : %@",[NSString stringWithFormat:@"Bearer %@", sesion.token]);
    [_sharedInstance.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", sesion.token] forHTTPHeaderField:@"Authorization"];
    return _sharedInstance;
}

// Get saved session

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        [self setResponseSerializer:[AFJSONResponseSerializer serializer]];
        [self.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/plain", @"text/html", @"image/jpeg", nil]];
        //set header, get from saved token.
//        FCOSessionModel *sesion = [FCOSessionModel sharedInstance];
//        [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", sesion.token]
//                      forHTTPHeaderField:@"Authorization"];
    }

    return self;
}
@end
