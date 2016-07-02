//
//  FCOCommentModel.m
//  fco
//
//  Created by Kryptonite on 7/29/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOCommentModel.h"

@implementation FCOCommentModel

- (id)initWithDictionary:(NSDictionary *)info {
    self = [super init];
    if (self) {
        self._id = info[@"id"];
        self.user_id = info[@"user_id"];
        self.callout_id = info[@"callout_id"];
        self.details = info[@"details"];
        self.status = info[@"status"];
        self.created_at = info[@"created_at"];
        self.updated_at = info[@"updated_at"];
        
        self.user_firstName = info[@"user"][@"first_name"];
        self.user_lastName = info[@"user"][@"last_name"];
        self.user_photo = info[@"user"][@"photo"];
    }
    return self;
}

-(void)updateWithDictionary:(NSDictionary *)info{
    self._id = info[@"id"];
    self.user_id = info[@"user_id"];
    self.callout_id = info[@"callout_id"];
    self.details = info[@"details"];
    self.status = info[@"status"];
    self.created_at = info[@"created_at"];
    self.updated_at = info[@"updated_at"];
    
    self.user_firstName = info[@"user"][@"first_name"];
    self.user_lastName = info[@"user"][@"last_name"];
    self.user_photo = info[@"user"][@"photo"];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self._id forKey:@"_id"];
    [encoder encodeObject:self.user_id forKey:@"user_id"];
    [encoder encodeObject:self.callout_id forKey:@"callout_id"];
    [encoder encodeObject:self.details forKey:@"details"];
    [encoder encodeObject:self.status forKey:@"status"];
    [encoder encodeObject:self.created_at forKey:@"created_at"];
    [encoder encodeObject:self.updated_at forKey:@"updated_at"];
    
    [encoder encodeObject:self.user_firstName forKey:@"user_firstName"];
    [encoder encodeObject:self.user_lastName forKey:@"user_lastName"];
    [encoder encodeObject:@"user_photo" forKey:@"user_photo"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self._id = [decoder decodeObjectForKey:@"_id"];
        self.user_id = [decoder decodeObjectForKey:@"user_id"];
        self.callout_id = [decoder decodeObjectForKey:@"callout_id"];
        self.details = [decoder decodeObjectForKey:@"details"];
        self.status = [decoder decodeObjectForKey:@"status"];
        self.created_at = [decoder decodeObjectForKey:@"created_at"];
        self.updated_at = [decoder decodeObjectForKey:@"updated_at"];
        
        self.user_firstName = [decoder decodeObjectForKey:@"user_firstName"];
        self.user_lastName = [decoder decodeObjectForKey:@"user_lastName"];
        self.user_photo = [decoder decodeObjectForKey:@"user_photo"];
    }
    return self;
}

@end
