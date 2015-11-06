//
//  APIClient.m
//  ImageSearcher
//
//  Created by Nathan Arnold on 11/5/15.
//  Copyright © 2015 Nathan Arnold. All rights reserved.
//

#import "APIClient.h"
#import "Constants.h"

@implementation APIClient

static NSString * const BASE_URL = @"https://ajax.googleapis.com/";

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (instancetype)init {
    
    if (self = [super initWithBaseURL:[NSURL URLWithString:BASE_URL] ]) {
        
        AFJSONRequestSerializer *requestSerializer =[[AFJSONRequestSerializer alloc]init];
        [requestSerializer setValue:@"http://gingerandthecyclist.com" forHTTPHeaderField:@"Referer"];

        self.requestSerializer = requestSerializer;

        AFJSONResponseSerializer *responseSerializer = [[AFJSONResponseSerializer alloc]init];
        responseSerializer.removesKeysWithNullValues = true;
        self.responseSerializer = responseSerializer;
        
        
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
    }
    
    return self;
}



- (nullable NSURLSessionDataTask *)getResultsForSearch:(NSString *)searchTerm
                                                  page:(NSInteger)page
                                               success:(nullable void (^)(NSURLSessionDataTask *task, id responseObject))success
                                               failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    NSParameterAssert(searchTerm);
    
    NSDictionary *params = @{@"v":@"1.0", @"q":searchTerm, @"start":[NSNumber numberWithInteger:page]};
    return [self GET:@"/ajax/services/search/images" parameters:params success:success failure:failure];
    
}


#pragma mark - Private

- (void)addHeaders {
    [self.requestSerializer setValue:@"http://gingerandthecyclist.com" forHTTPHeaderField:@"referer"];
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    
    DLog(@"%@ %@", [request HTTPMethod], [request URL]);
    
    return [super dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        DLog(@"%@: %@\n%@", [response URL], [error localizedDescription], responseObject);
        
        if (completionHandler){
            completionHandler(response,responseObject,error);
        }
        
    }];
}

@end
