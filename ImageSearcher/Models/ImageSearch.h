//
//  ImageSearch.h
//  ImageSearcher
//
//  Created by Nathan Arnold on 11/5/15.
//  Copyright © 2015 Nathan Arnold. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageSearch : NSObject

@property (strong, readonly) NSString *query;
@property (readonly) NSInteger currentPage;
@property (readonly) NSUInteger numberOfResults;


- (instancetype)initWithQuery:(NSString *)query;

- (void)executeWithComplete:(void(^)(NSArray *results, NSError *error))complete;

- (void)getMoreResultsWithComplete:(void(^)(NSArray *results, NSError *error))complete;

- (void)cancel;

- (NSArray *)results;

// Return YES if there are still operations in progress
- (BOOL)isRetrievingImages;

// Return YES if there are no more images to get
- (BOOL)isFinished;

- (NSUInteger)numberOfRequests;

@end
