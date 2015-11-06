//
//  ImageSearch.m
//  ImageSearcher
//
//  Created by Nathan Arnold on 11/5/15.
//  Copyright © 2015 Nathan Arnold. All rights reserved.
//

#import "ImageSearch.h"
#import "APIClient.h"
#import "ImageSearchResult.h"

#import "Constants.h"

@interface ImageSearch ()

@property (strong) NSMutableArray *mutableResults;
@property (strong) NSMutableArray *requests;



@end

@implementation ImageSearch


- (instancetype)initWithQuery:(NSString *)query {
    
    if (self = [super init]) {
        _query = query;
        self.requests = [NSMutableArray array];
    }
    
    return self;
}

- (void)executeWithComplete:(void (^)(NSArray *, NSError *))complete {
    [self getResultsForPage:0 complete:complete];
}

- (void)getMoreResultsWithComplete:(void(^)(NSArray *results, NSError *error))complete {
    _currentPage++;
    [self getResultsForPage:self.currentPage complete:complete];
}

- (void)getResultsForPage:(NSInteger) page complete:(void (^)(NSArray *, NSError *))complete {
    
    NSURLSessionDataTask *task = [[APIClient sharedInstance]getResultsForSearch:self.query
                                                                           page:page*4
                                                                        success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
                                                                            
                                                                            [self.requests removeObject:task];

                                                                            if (!self.mutableResults) {
                                                                                self.mutableResults = [NSMutableArray array];
                                                                            }
                                                                            
                                                                            NSArray *imagesFromRequest = [[self resultsForResponseObject:responseObject] copy];
                                                                            [self.mutableResults addObjectsFromArray:imagesFromRequest];
                                                                            
                                                                            
                                                                            if (complete) {
                                                                                complete(imagesFromRequest, nil);
                                                                            }
                                                                            
                                                                        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                                                                            
                                                                            [self.requests removeObject:task];
                                                                            
                                                                            if (complete) {
                                                                                complete(nil,error);
                                                                            }
                                                                        }];
    
    [self.requests addObject:task];

}

- (NSMutableArray *)resultsForResponseObject:(id)responseObject {
    
    NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"responseObject is NOT NSDictionary");

    NSDictionary *response = (NSDictionary *)responseObject;
    NSDictionary *responseData = response[@"responseData"];
    
    if (!responseData){
        DLog(@"WARNING: responseData is nil");
        return nil;
    }
    
    //Results should be an array of dictionaries
    NSArray *results = responseData[@"results"];
    NSMutableArray *searchResults = [NSMutableArray arrayWithCapacity:[results count]];
    
    for (NSDictionary *resultDict in results) {
        ImageSearchResult *result = [[ImageSearchResult alloc]initWithDictionary:resultDict];
        [searchResults addObject:result];
    }
    
    return searchResults;
}

- (void)cancel {
  
    for (NSURLSessionDataTask *task in self.requests){
        [task cancel];
    }

    [self.requests removeAllObjects];
}


- (NSArray *)results {
    return [self.mutableResults copy];
}

- (BOOL)isRetrievingImages {
    
    for (NSURLSessionDataTask *task in self.requests){
        [task cancel];
        if ([task state]==NSURLSessionTaskStateRunning){
            return YES;
        }
    }
    return  NO;
}

- (BOOL)isFinished {
    return ([self.results count] >= self.numberOfResults);
}

- (NSUInteger)numberOfRequests {
    
    return [self.requests count];
}

@end
