//
//  FCOCalloutModel.m
//  fco
//
//  Created by Kryptonite on 7/2/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOCalloutModel.h"

@implementation FCOCalloutModel


- (id)initWithDictionary:(NSDictionary *)info {
    self = [super init];
    
    if (self) {
        if ([info isKindOfClass:[NSDictionary class]]) {
            self._id = info[@"id"];
            self.user_id = info[@"user_id"];
            self.category_id = info[@"category_id"];
            self.title = info[@"title"];
            self.desc = info[@"description"];
            self.fighter_a = info[@"fighter_a"];
            self.fighter_b = info[@"fighter_b"];
            self.photo = info[@"photo"];
            self.category_id = info[@"category_id"];
            self.photo = info[@"photo"];
            self.video = info[@"video"];
            self.match_type = info[@"match_type"];
            self.details_date = info[@"details_date"];
            self.details_time = info[@"details_time"];
            self.details_venue = info[@"details_venue"];
            self.total_comments = info[@"total_comments"];
            self.total_views = info[@"total_views"];
            self.total_votes = info[@"total_votes"];
            self.status = info[@"status"];
            self.created_at = info[@"created_at"];
            self.updated_at = info[@"updated_at"];
            self.user_first_name = info[@"user"][@"first_name"];
            self.user_last_name = info[@"user"][@"last_name"];
            self.user_photo = info[@"user"][@"photo"];
            self.category = info[@"category"][@"description"];
            self.comment = info[@"comment"][@"details"];
            self.latitude = info[@"latitude"];
            self.longitude = info[@"longitude"];
            self.broadcast_url = info[@"broadcast_url"];
            self.ticket_url = info[@"ticket_url"];
            self.down = info[@"down"];
            self.up = info[@"up"];
        } else {
            return nil;
        }

    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self._id forKey:@"_id"];
    [encoder encodeObject:self.user_id forKey:@"user_id"];
    [encoder encodeObject:self.category_id forKey:@"category_id"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.desc forKey:@"description"];
    [encoder encodeObject:self.fighter_a forKey:@"fighter_a"];
    [encoder encodeObject:self.fighter_b forKey:@"fighter_b"];
    [encoder encodeObject:self.photo forKey:@"photo"];
    [encoder encodeObject:self.video forKey:@"video"];
    [encoder encodeObject:self.match_type forKey:@"match_type"];
    [encoder encodeObject:self.details_date forKey:@"details_date"];
    [encoder encodeObject:self.details_time forKey:@"details_time"];
    [encoder encodeObject:self.details_venue forKey:@"details_venue"];
    [encoder encodeObject:self.total_comments forKey:@"total_comments"];
    [encoder encodeObject:self.total_views forKey:@"total_views"];
    [encoder encodeObject:self.total_votes forKey:@"total_votes"];
    [encoder encodeObject:self.status forKey:@"status"];
    [encoder encodeObject:self.created_at forKey:@"created_at"];
    [encoder encodeObject:self.updated_at forKey:@"updated_at"];
    [encoder encodeObject:self.user_first_name forKey:@"user_first_name"];
    [encoder encodeObject:self.user_last_name forKey:@"user_last_name"];
    [encoder encodeObject:self.user_photo forKey:@"user_photo"];
    [encoder encodeObject:self.category forKey:@"category"];
    
    //comment
    [encoder encodeObject:self.comment forKey:@"comment"];
    [encoder encodeObject:self.latitude forKey:@"latitude"];
    [encoder encodeObject:self.longitude forKey:@"longitude"];
    [encoder encodeObject:self.broadcast_url forKey:@"broadcast_url"];
    [encoder encodeObject:self.ticket_url forKey:@"ticket_url"];
    [encoder encodeObject:self.down forKey:@"down"];
    [encoder encodeObject:self.up forKey:@"up"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self._id = [decoder decodeObjectForKey:@"_id"];
        self.user_id = [decoder decodeObjectForKey:@"user_id"];
        self.category_id = [decoder decodeObjectForKey:@"category_id"];
        self.title = [decoder decodeObjectForKey:@"title"];
        self.desc = [decoder decodeObjectForKey:@"description"];
        self.fighter_a = [decoder decodeObjectForKey:@"fighter_a"];
        self.fighter_b = [decoder decodeObjectForKey:@"fighter_b"];
        self.photo = [decoder decodeObjectForKey:@"photo"];
        self.video = [decoder decodeObjectForKey:@"video"];
        self.match_type = [decoder decodeObjectForKey:@"match_type"];
        self.details_date = [decoder decodeObjectForKey:@"details_date"];
        self.details_time = [decoder decodeObjectForKey:@"details_time"];
        self.details_venue = [decoder decodeObjectForKey:@"details_venue"];
        self.total_comments = [decoder decodeObjectForKey:@"total_comments"];
        self.total_views = [decoder decodeObjectForKey:@"total_views"];
        self.total_votes = [decoder decodeObjectForKey:@"total_votes"];
        self.status = [decoder decodeObjectForKey:@"status"];
        self.created_at = [decoder decodeObjectForKey:@"created_at"];
        self.updated_at = [decoder decodeObjectForKey:@"updated_at"];
        self.user_first_name = [decoder decodeObjectForKey:@"user_first_name"];
        self.user_last_name = [decoder decodeObjectForKey:@"user_last_name"];
        self.user_photo = [decoder decodeObjectForKey:@"user_photo"];
        self.category = [decoder decodeObjectForKey:@"category"];
        
        //comment
        self.comment = [decoder decodeObjectForKey:@"comment"];
        
        self.latitude = [decoder decodeObjectForKey:@"latitude"];
        self.longitude = [decoder decodeObjectForKey:@"longitude"];
        self.broadcast_url = [decoder decodeObjectForKey:@"broadcast_url"];
        self.ticket_url = [decoder decodeObjectForKey:@"ticket_url"];
        self.down = [decoder decodeObjectForKey:@"down"];
        self.up = [decoder decodeObjectForKey:@"up"];
    }
    return self;
}


@end
