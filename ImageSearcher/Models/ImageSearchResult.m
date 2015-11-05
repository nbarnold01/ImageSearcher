//
//  ImageSearchResult.m
//  ImageSearcher
//
//  Created by Nathan Arnold on 11/5/15.
//  Copyright © 2015 Nathan Arnold. All rights reserved.
//

#import "ImageSearchResult.h"

@implementation ImageSearchResult

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {

    if (self = [super init]) {
        _imageID = dictionary[@"imageID"];
        _title = dictionary[@"title"];
        _contentDescription = dictionary[@"contentDescription"];
        _URL = [NSURL URLWithString:dictionary[@"url"]];
        _thumbURL = [NSURL URLWithString:dictionary[@"tbUrl"]];
    }
    
    return self;
}

@end
