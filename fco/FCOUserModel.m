//
//  FCOUserModel.m
//  fco
//
//  Created by Kryptonite on 6/29/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOUserModel.h"

@implementation FCOUserModel

- (id)initWithDictionary:(NSDictionary *)info {
    self = [super init];
    
    if (self) {
        self._id = info[@"id"];
        self.first_name = info[@"first_name"];
        self.last_name = info[@"last_name"];
        self.name = info[@"name"];
        self.username = info[@"username"];
        self.email = info[@"email"];
        self.role_id = info[@"role_id"];
        self.category_id = info[@"category_id"];
        self.country_id = info[@"country_id"];
        self.photo = info[@"photo"];
        self.reset_password_token = info[@"reset_password_token"];
        self.reset_password_expiration = info[@"reset_password_expiration"];
        self.birth_date = info[@"birth_date"];
        self.gender = info[@"gender"];
        self.status = info[@"status"];
        self.created_at = info[@"created_at"];
        self.updated_at = info[@"updated_at"];
        self.role_desc = info[@"role"][@"description"];
        self.category_desc = info[@"category"][@"description"];
        if (info[@"country"] != [NSNull null]) {
            self.country_desc = info[@"country"][@"description"];
        }
        
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self._id forKey:@"_id"];
    [encoder encodeObject:self.first_name forKey:@"first_name"];
    [encoder encodeObject:self.last_name forKey:@"last_name"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.username forKey:@"username"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.role_id forKey:@"role_id"];
    [encoder encodeObject:self.category_id forKey:@"category_id"];
    [encoder encodeObject:self.country_id forKey:@"country_id"];
    [encoder encodeObject:self.photo forKey:@"photo"];
    [encoder encodeObject:self.reset_password_token forKey:@"reset_password_token"];
    [encoder encodeObject:self.reset_password_expiration forKey:@"reset_password_expiration"];
    [encoder encodeObject:self.birth_date forKey:@"birth_date"];
    [encoder encodeObject:self.gender forKey:@"gender"];
    [encoder encodeObject:self.status forKey:@"status"];
    [encoder encodeObject:self.created_at forKey:@"created_at"];
    [encoder encodeObject:self.updated_at forKey:@"updated_at"];
    [encoder encodeObject:self.role_desc forKey:@"role_desc"];
    [encoder encodeObject:self.category_desc forKey:@"category_desc"];
    [encoder encodeObject:self.country_desc forKey:@"country_desc"];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self._id = [decoder decodeObjectForKey:@"_id"];
        self.first_name = [decoder decodeObjectForKey:@"first_name"];
        self.last_name = [decoder decodeObjectForKey:@"last_name"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.username = [decoder decodeObjectForKey:@"username"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.role_id = [decoder decodeObjectForKey:@"role_id"];
        self.category_id = [decoder decodeObjectForKey:@"category_id"];
        self.category_id = [decoder decodeObjectForKey:@"category_id"];
        self.country_id = [decoder decodeObjectForKey:@"country_id"];
        self.photo = [decoder decodeObjectForKey:@"photo"];
        self.reset_password_token = [decoder decodeObjectForKey:@"reset_password_token"];
        self.reset_password_expiration = [decoder decodeObjectForKey:@"reset_password_expiration"];
        self.birth_date = [decoder decodeObjectForKey:@"birth_date"];
        self.gender = [decoder decodeObjectForKey:@"gender"];
        self.status = [decoder decodeObjectForKey:@"status"];
        self.created_at = [decoder decodeObjectForKey:@"created_at"];
        self.updated_at = [decoder decodeObjectForKey:@"updated_at"];
        self.role_desc = [decoder decodeObjectForKey:@"role_desc"];
        self.category_desc = [decoder decodeObjectForKey:@"category_desc"];
        self.country_desc = [decoder decodeObjectForKey:@"country_desc"];
    }
    return self;
}

@end
