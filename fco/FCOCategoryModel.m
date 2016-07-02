//
//  FCOCategoryModel.m
//  fco
//
//  Created by Kryptonite on 6/30/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOCategoryModel.h"

@implementation FCOCategoryModel

-(id)initWithDictionary:(NSDictionary *)info {
    self = [super init];
    
    if (self) {
        self._id = info[@"id"];
        self.desc = info[@"description"];
        self.status = info[@"status"];
        self.created_at = info[@"created_at"];
        self.updated_at = info[@"updated_at"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self._id forKey:@"_id"];
    [encoder encodeObject:self.desc forKey:@"description"];
    [encoder encodeObject:self.status forKey:@"status"];
    [encoder encodeObject:self.created_at forKey:@"created_at"];
    [encoder encodeObject:self.updated_at forKey:@"updated_at"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self._id = [decoder decodeObjectForKey:@"_id"];
        self.desc = [decoder decodeObjectForKey:@"description"];
        self.status = [decoder decodeObjectForKey:@"status"];
        self.created_at = [decoder decodeObjectForKey:@"created_at"];
        self.updated_at = [decoder decodeObjectForKey:@"updated_at"];
    }
    return self;
}

@end
