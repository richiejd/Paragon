//
//  PGAPIClient.h
//  Pods
//
//  Created by Richie Davis on 7/26/15.
//
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"

typedef void (^PGCompletion)(id response, id error);
typedef void (^PGCompletionWithCode)(NSInteger statusCode, id response, id error);
typedef void (^AFSuccess)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^AFFailure)(AFHTTPRequestOperation *operation, NSError *error);

/**
 `PGAPIClient` is a subclass of `NSObject` and utilizes `PGNetworkingManager`, `PGObjectMapping`,  and `PGEndpointRequest` to create a convenient way to hit web API endpoints in an organized and succinct manner. For this class to work properly, it requires that the developer working with it has stored endpoints in the `PGNetworkingManager`
 ## Subclassing Notes
 This class is intended to be subclassed. As a standard, there should be one PGAPIClient per view controller to make the view controller's requests easily cancellable upone completion. If you wish to have requests made that are not directly coupled to a view controller, then you should create a singleton object for performing such requests. This can be done in the following manner within a subclass:
 + (instancetype)sharedAPIClient
 {
 static ExampleSubclassedAPIClient *instance;
 static dispatch_once_t onceToken;
 dispatch_once(&onceToken, ^{
 instance = [[ExampleSubclassedAPIClient alloc] init];
 });
 return instance;
 }

 then use this instance by calling [ExampleSubclassedAPIClient sharedAPIClient]
 ## Methods to Override
 If you want to override the header structure used so that it is dynamic, please override `headersForRequest:`, the existing behavior simply gets your standard headers from `PGNetworkingManager` if you wish this behavior to continue, then after handling any of your curtom header cases, as a final case simply call [super headersForRequest:]
 */
@interface PGAPIClient : NSObject

/**
 Performs an endpoint request and includes all required mappings
 @param key The key for the `PGEndpointRequest` stored in `PGNetworkingManager`
 @param suffix The suffix to add on to the end of the request url
 @param params The query params that will be added to the request
 @param object The body object to be sent with the request
 @param headers The headers to be added to the request
 @param completion The completion block that will be executed upon the request's return
 ^(NSInteger statusCode, id response, id error)
 @return The newly-initialized HTTP client
 */
- (void)performRequestWithEndpoint:(id)key
                        pathSuffix:(NSString *)suffix
                            params:(NSDictionary *)params
                            object:(id)object
                           headers:(NSDictionary *)headers
                completionWithCode:(PGCompletionWithCode)completion;

/**
 Performs an endpoint request and includes all required mappings
 @param key The key for the `PGEndpointRequest` stored in `PGNetworkingManager`
 @param suffix The suffix to add on to the end of the request url
 @param params The query params that will be added to the request
 @param object The body object to be sent with the request
 @param headers The headers to be added to the request
 @param completion The completion block that will be executed upon the request's return
 ^(id response, id error)
 @return The newly-initialized HTTP client
 */
- (void)performRequestWithEndpoint:(id)key
                        pathSuffix:(NSString *)suffix
                            params:(NSDictionary *)params
                            object:(id)object
                           headers:(NSDictionary *)headers
                        completion:(PGCompletion)completion;

@end
