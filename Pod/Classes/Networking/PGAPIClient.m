//
//  PGAPIClient.m
//  Pods
//
//  Created by Richie Davis on 7/26/15.
//
//

#import "PGAPIClient.h"
#import "AFHTTPRequestOperationManager.h"
#import "PGEndpointRequest.h"
#import "PGNetworkingManager.h"
#import "PGObjectMapping.h"
#import "PGMappableObject.h"
#import "NSString+PG.h"
#import "NSDictionary+PG.h"

@interface PGAPIClient ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *formRequestManager;
@property (nonatomic, strong) AFHTTPRequestOperationManager *jsonRequestManager;

@end

@implementation PGAPIClient

#pragma mark Endpoint Request

- (void)performRequestWithEndpoint:(id)key
                        pathSuffix:(NSString *)suffix
                            params:(NSDictionary *)params
                            object:(id)object
                           headers:(NSDictionary *)headers
                completionWithCode:(PGCompletionWithCode)completion
{
  PGEndpointRequest *request = [PGNetworkingManager requestForKey:key];
  if (!request) completion(500, nil, nil);

  NSString *requestURL = request.url.absoluteString;

  // append the path suffix
  if (suffix) requestURL = [NSString stringWithFormat:@"%@%@", requestURL, suffix];

  // append the query string
  if (params) requestURL = [NSString stringByAppendingParams:params toString:requestURL];

  // if object present then must have a mapping to match
  NSDictionary *requestBody;
  if (object) {
    NSAssert(request.bodyClass, @"You must provide a mapping class for the body");
    NSAssert([object isKindOfClass:request.bodyClass], @"Your request object does not match the mapping object");
    PGObjectMapping *mapping = [request.bodyClass mapping];
    requestBody = [mapping dictionaryFromObject:object];

    if (request.rootBodyKey) {
      NSArray *keys = [request.rootBodyKey componentsSeparatedByString:@"."];
      requestBody = [NSDictionary dictionaryFromKeyArray:keys finalObject:requestBody];
    }
  }

  headers = headers ? headers : [self headersForRequest:request];
  [self setRequestHeaders:headers forRequestType:request.encodingType];

  AFSuccess success = [self successFromRequest:request block:completion];
  AFFailure failure = [self failureFromRequest:request block:completion];
  AFHTTPRequestOperationManager *manager = [self managerForType:request.encodingType];

  switch (request.requestType) {
    case RequestTypeGET:
      [manager GET:requestURL parameters:requestBody success:success failure:failure];
      break;
    case RequestTypePOST:
      [manager POST:requestURL parameters:requestBody success:success failure:failure];
      break;
    case RequestTypePUT:
      [manager PUT:requestURL parameters:requestBody success:success failure:failure];
      break;
    case RequestTypeDELETE:
      [manager DELETE:requestURL parameters:requestBody success:success failure:failure];
      break;
  }
}

- (void)performRequestWithEndpoint:(id)key
                        pathSuffix:(NSString *)suffix
                            params:(NSDictionary *)params
                            object:(id)object
                           headers:(NSDictionary *)headers
                        completion:(PGCompletion)completion
{
  [self performRequestWithEndpoint:key
                        pathSuffix:suffix
                            params:params
                            object:object
                           headers:headers
                completionWithCode:[self transformCompletion:completion]];
}

- (void)setRequestHeaders:(NSDictionary *)headers forRequestType:(RequestEncodingMIMEType)type
{
  AFHTTPRequestOperationManager *manager = [self managerForType:type];
  for (id key in headers) {
    [manager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
  }
}

// override for custom header usage
- (NSDictionary *)headersForRequest:(PGEndpointRequest *)request
{
  return [PGNetworkingManager objectManager].requestHeaders;
}

#pragma mark Request Managers

- (AFHTTPRequestOperationManager *)formRequestManager
{
  if (!_formRequestManager) {
    _formRequestManager = [AFHTTPRequestOperationManager manager];
    _formRequestManager.requestSerializer = [AFHTTPRequestSerializer serializer];
  }

  return _formRequestManager;
}

- (AFHTTPRequestOperationManager *)jsonRequestManager
{
  if (!_jsonRequestManager) {
    _jsonRequestManager = [AFHTTPRequestOperationManager manager];
    _jsonRequestManager.requestSerializer = [AFJSONRequestSerializer serializer];
  }

  return _jsonRequestManager;
}

- (AFHTTPRequestOperationManager *)managerForType:(RequestEncodingMIMEType)type
{
  AFHTTPRequestOperationManager *manager;
  switch (type) {
    case RequestEncodingMIMETypeForm:
      manager = [self formRequestManager];
      break;
    case RequestEncodingMIMETypeJSON:
      manager = [self jsonRequestManager];
      break;
  }

  return manager;
}

#pragma mark Client Helpers

- (id)objectFromJSON:(NSDictionary *)dictionary root:(NSString *)root mappingClass:(Class)mappingClass
{
  if (!dictionary) return nil;

  if (root) {
    NSArray *keys = [root componentsSeparatedByString:@"."];
    for (NSString *key in keys) {
      dictionary = dictionary[key];
    }
  }

  return [[mappingClass mapping] objectFromDictionary:dictionary];
}

- (PGCompletionWithCode)transformCompletion:(PGCompletion)completion
{
  return ^(NSInteger statusCode, id response, id error) {
    if (completion) completion(response, error);
  };
}

- (AFSuccess)successFromRequest:(PGEndpointRequest *)request block:(PGCompletionWithCode)block
{
  return ^(AFHTTPRequestOperation *operation, id responseObject) {
    id responseObj = responseObject;
    if (request.responseClass) {
      responseObj = [self objectFromJSON:responseObject
                                    root:request.rootResponseKey
                            mappingClass:request.responseClass];
    }
    if (block) block(operation.response.statusCode, responseObj, nil);
  };
}

- (AFFailure)failureFromRequest:(PGEndpointRequest *)request block:(PGCompletionWithCode)block
{
  return ^(AFHTTPRequestOperation *operation, NSError *error) {
    id errorObj = error;
    if (request.errorClass) {
      errorObj = [self objectFromJSON:operation.responseObject
                                 root:request.rootErrorKey
                         mappingClass:request.errorClass];
    }
    if (block) block(operation.response.statusCode, nil, errorObj);
  };
}

@end
