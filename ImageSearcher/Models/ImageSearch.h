//
//  ImageSearch.h
//  ImageSearcher
//
//  Created by Nathan Arnold on 11/5/15.
//  Copyright © 2015 Nathan Arnold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@interface ImageSearch : NSManagedObject 

@property (strong, readonly) NSString *searchString;
@property (readonly) NSUInteger numberOfResults;
@property (readonly, strong) NSDate *createdOn;


+ (instancetype)queryForSearchString:(NSString *)searchString managedObjectContext:(NSManagedObjectContext *)context;

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
