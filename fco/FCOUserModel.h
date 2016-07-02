//
//  FCOUserModel.h
//  fco
//
//  Created by Kryptonite on 6/29/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FCOUserModel : NSObject
@property NSString *_id; //id
@property NSString *first_name;
@property NSString *last_name;
@property NSString *name;
@property NSString *username;
@property NSString *email;
@property NSString *role_id;
@property NSString *category_id;
@property NSString *country_id;
@property NSString *photo;
@property NSString *reset_password_token;
@property NSString *reset_password_expiration;
@property NSString *birth_date;
@property NSString *gender;
@property NSString *status;
@property NSString *created_at;
@property NSString *updated_at;
@property NSString *role_desc;
@property NSString *category_desc;
@property NSString *country_desc;

- (id)initWithDictionary:(NSDictionary *)info;
@end
