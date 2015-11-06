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
        _imageID = dictionary[@"imageId"];
        _title = dictionary[@"titleNoFormatting"];
        _contentDescription = dictionary[@"contentNoFormatting"];
        _URL = [NSURL URLWithString:dictionary[@"url"]];
        _thumbURL = [NSURL URLWithString:dictionary[@"tbUrl"]];
        
        CGFloat thumbWidth = [dictionary[@"tbWidth"] floatValue];
        CGFloat thumbHeight = [dictionary[@"tbHeight"] floatValue];
        _thumbSize = CGSizeMake(thumbWidth, thumbHeight);
        
        CGFloat width = [dictionary[@"width"] floatValue];
        CGFloat height = [dictionary[@"height"] floatValue];
        _size = CGSizeMake(width, height);
    }
    
    return self;
}

@end
