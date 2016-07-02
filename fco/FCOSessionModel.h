//
//  FCOSessionModel.h
//  fco
//
//  Created by delmarz on 6/14/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCOUserModel.h"
#import "FCOCategoryModel.h"
#import "FCOCalloutModel.h"

@interface FCOSessionModel : NSObject
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) FCOUserModel *activeUser;
@property (nonatomic, strong) FCOCalloutModel *activeCallout;
+ (FCOSessionModel *)sharedInstance;
- (BOOL)isLoggedIn;
@end
