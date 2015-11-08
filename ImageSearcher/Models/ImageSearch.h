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

@property (readonly) BOOL isFinished;


+ (instancetype)queryForSearchString:(NSString *)searchString managedObjectContext:(NSManagedObjectContext *)context;

//Resets the query and removes the results. Returns the incremental results gained from one requests. Adds those results to the 'results' array
- (void)executeWithComplete:(void(^)(NSArray *results, NSError *error))complete;

//Pulls subsequent pages. Returns the incremental results gained from one requests. Adds those results to the 'results' array
- (void)getMoreResultsWithComplete:(void(^)(NSArray *results, NSError *error))complete;

//Cancel all requests being made
- (void)cancel;

//All the results received so far. All results are removed when 'executeWithComplete:' is called
- (NSArray *)results;

// Return YES if there are still operations in progress
- (BOOL)isRetrievingImages;

// Return YES if there are no more images to get
- (BOOL)isFinished;

- (NSUInteger)numberOfRequests;

@end
