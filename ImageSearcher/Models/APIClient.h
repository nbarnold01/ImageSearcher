//
//  APIClient.h
//  ImageSearcher
//
//  Created by Nathan Arnold on 11/5/15.
//  Copyright © 2015 Nathan Arnold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface APIClient : AFHTTPSessionManager


+ (nonnull instancetype)sharedInstance;

/*! Query the server for images matching query
 * \param searchTerm - String used to describe images. Must not be nil.
 * \param success - Block called on successful return of the network call
 * \param failure - Block called on unsuccessful return of the network call
 * \return - Operation object
 */
- (nullable NSURLSessionDataTask *)getResultsForSearch:(nullable NSString *)searchTerm
                                               success:(nullable void (^)( NSURLSessionDataTask * _Nullable task, _Nullable id responseObject))success
                                               failure:(nullable void (^)(NSURLSessionDataTask *_Nullable task, NSError *_Nullable error))failure;


@end
