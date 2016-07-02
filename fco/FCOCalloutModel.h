//
//  FCOCalloutModel.h
//  fco
//
//  Created by Kryptonite on 7/2/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FCOCalloutModel : NSObject

@property NSString *_id;
@property NSString *user_id;
@property NSString *category_id;
@property NSString *title;
@property NSString *desc;
@property NSString *fighter_a;
@property NSString *fighter_b;
@property NSString *photo;
@property NSString *video;
@property NSString *match_type;
@property NSString *details_date;
@property NSString *details_time;
@property NSString *details_venue;
@property NSString *total_comments;
@property NSString *total_views;
@property NSString *total_votes;
@property NSString *status;
@property NSString *created_at;
@property NSString *updated_at;
@property NSString *user_first_name;
@property NSString *user_last_name;
@property NSString *user_photo;
@property NSString *category;
@property NSString *comment;
@property NSString *latitude;
@property NSString *longitude;
@property NSString *broadcast_url;
@property NSString *ticket_url;
@property NSString *down;
@property NSString *up;

- (id)initWithDictionary:(NSDictionary *)info;


@end
