//
//  ImageSearchResult.h
//  ImageSearcher
//
//  Created by Nathan Arnold on 11/5/15.
//  Copyright © 2015 Nathan Arnold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageSearchResult : NSObject

@property (strong, readonly) NSString *imageID;
@property (strong, readonly) NSString *title;
@property (strong, readonly) NSString *contentDescription;

//fullsize image
@property (strong, readonly) NSURL *URL;
@property (assign, readonly) CGSize size;

//thumbnail image
@property (strong, readonly) NSURL *thumbURL;
@property (assign, readonly) CGSize thumbSize;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
