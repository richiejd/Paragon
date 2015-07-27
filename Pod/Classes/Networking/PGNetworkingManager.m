//
//  PGNetworkingManager.m
//  Pods
//
//  Created by Richie Davis on 7/26/15.
//
//

#import "PGNetworkingManager.h"
#import "PGEndpointRequest.h"

@interface PGNetworkingManager ()

@property (nonatomic, strong, readwrite) NSURL *baseUrl;
@property (nonatomic, strong, readwrite) Class errorClass;
@property (nonatomic, readwrite) RequestEncodingMIMEType encodingType;
@property (nonatomic, copy, readwrite) NSDictionary *requestHeaders;

@property (nonatomic, copy) NSDictionary *endpoints;

@end

@implementation PGNetworkingManager

+ (instancetype)objectManager;
{
  static PGNetworkingManager *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[PGNetworkingManager alloc] init];
    instance.baseUrl = [NSURL URLWithString:@""];
    instance.errorClass = nil;
    instance.encodingType = RequestAcceptEncodingMIMETypeForm;
    instance.requestHeaders = @{};
  });
  return instance;
}

+ (void)setupWithBaseUrl:(NSURL *)baseUrl
              errorClass:(Class)errorClass
            encodingType:(RequestEncodingMIMEType)encodingType
                 headers:(NSDictionary *)requestHeaders
{
  PGNetworkingManager *manager = [PGNetworkingManager objectManager];
  manager.baseUrl = baseUrl;
  manager.errorClass = errorClass;
  manager.encodingType = encodingType;
  manager.requestHeaders = requestHeaders;
}

+ (void)updateWithHeaders:(NSDictionary *)headers
{
  [PGNetworkingManager objectManager].requestHeaders = headers;
}

+ (void)storeEndpoints:(NSArray *)endpoints
{
  NSMutableDictionary *newEndpoints = [[NSMutableDictionary alloc] init];
  for (PGEndpointRequest *endpoint in endpoints) {
    NSAssert([endpoint isKindOfClass:[PGEndpointRequest class]],
             @"One of the objects being stored in the networking manager is not an endpoint request, all objects must be endpoint requests.");
    newEndpoints[endpoint.key] = endpoint;
  }

  [newEndpoints addEntriesFromDictionary:[PGNetworkingManager objectManager].endpoints];
  [PGNetworkingManager objectManager].endpoints = newEndpoints;
}

+ (PGEndpointRequest *)requestForKey:(id)key
{
  return [PGNetworkingManager objectManager].endpoints[key];
}

@end
