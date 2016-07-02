//
//  FCOHTTPClient.h
//  fco
//
//  Created by delmarz on 6/14/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface FCOHTTPClient : AFHTTPSessionManager
+ (FCOHTTPClient *)sharedInstance;
@end
