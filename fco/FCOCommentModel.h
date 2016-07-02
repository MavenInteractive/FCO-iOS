//
//  FCOCommentModel.h
//  fco
//
//  Created by Kryptonite on 7/29/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FCOCommentModel : NSObject

@property NSString *_id;
@property NSString *user_id;
@property NSString *callout_id;
@property NSString *details;
@property NSString *status;
@property NSString *created_at;
@property NSString *updated_at;

@property NSString *user_firstName;
@property NSString *user_lastName;
@property NSString *user_photo;

- (id)initWithDictionary:(NSDictionary *)info;

-(void)updateWithDictionary:(NSDictionary *)info;
@end
