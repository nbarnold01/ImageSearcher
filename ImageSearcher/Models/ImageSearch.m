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

@property (strong) NSMutableArray *results;
@property (nonatomic, strong) NSURL *nextPageURL;
@property (nonatomic, weak) NSURLSessionDataTask *requestTask;

@end

@implementation ImageSearch


- (instancetype)initWithQuery:(NSString *)query {
    
    if (self = [super init]) {
        _query = query;
    }
    
    return self;
}

- (void)executeWithComplete:(void (^)(NSArray *, NSError *))complete {
    
   self.requestTask = [[APIClient sharedInstance]getResultsForSearch:self.query
                                           success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {

        _results = [self resultsForResponseObject:responseObject];
        if (complete) {
            complete([self.results copy], nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
        if (complete) {
            complete(nil,error);
        }
    }];
}

- (NSMutableArray *)resultsForResponseObject:(id)responseObject {
    
    NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"responseObject is NOT NSDictionary");

    NSDictionary *response = (NSDictionary *)responseObject;
    NSDictionary *responseData = response[@"responseData"];
    
    if (!responseData){
        DLog(@"WARNING: responseData is nil");
        return nil;
    }
    
    _currentPage = [responseData[@"currentPageIndex"] unsignedIntegerValue];
    _nextPageURL = [NSURL URLWithString:responseData[@"moreResultsUrl"]];
    
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
  
    [self.requestTask cancel];
    self.requestTask = nil;
}

@end
