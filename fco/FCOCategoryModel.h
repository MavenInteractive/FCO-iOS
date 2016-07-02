//
//  FCOCategoryModel.h
//  fco
//
//  Created by Kryptonite on 6/30/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FCOCategoryModel : NSObject

@property NSString *_id;
@property NSString *desc;
@property NSString *status;
@property NSString *created_at;
@property NSString *updated_at;

-(id)initWithDictionary:(NSDictionary *)info;

@end
