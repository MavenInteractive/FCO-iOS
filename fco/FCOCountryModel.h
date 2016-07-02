//
//  FCOCountryModel.h
//  fco
//
//  Created by Kryptonite on 8/28/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FCOCountryModel : NSObject

@property NSString *_id;
@property NSString *code;
@property NSString *desc;
@property NSString *created_at;
@property NSString *updated_at;

- (id)initWithDictionary:(NSDictionary *)info;


@end
