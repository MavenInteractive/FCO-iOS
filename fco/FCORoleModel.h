//
//  FCORoleModel.h
//  fco
//
//  Created by Kryptonite on 7/1/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FCORoleModel : NSObject

@property NSString *_id;
@property NSString *desc;
@property NSString *status;
@property NSString *created_at;
@property NSString *updated_at;

- (id)initWithDictionary:(NSDictionary *)info;

@end
