//
//  ImageSearchResult.h
//  ImageSearcher
//
//  Created by Nathan Arnold on 11/5/15.
//  Copyright © 2015 Nathan Arnold. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageSearchResult : NSObject

@property (strong, readonly) NSString *imageID;
@property (strong, readonly) NSString *title;
@property (strong, readonly) NSString *contentDescription;
@property (strong, readonly) NSURL *URL;
@property (strong, readonly) NSURL *thumbURL;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
