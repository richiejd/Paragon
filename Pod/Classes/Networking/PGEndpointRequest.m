//
//  PGEndpointRequest.m
//  Pods
//
//  Created by Richie Davis on 7/26/15.
//
//

#import "PGEndpointRequest.h"
#import "PGNetworkingManager.h"
#import "PGObjectMapping.h"
#import "PGMappableObject.h"

@interface PGEndpointRequest ()

@property (nonatomic, strong, readwrite) id key;
@property (nonatomic, strong, readwrite) Class bodyClass;
@property (nonatomic, strong, readwrite) Class responseClass;
@property (nonatomic, strong, readwrite) Class errorClass;
@property (nonatomic, copy, readwrite) NSString *rootKey;
@property (nonatomic, copy, readwrite) NSURL *url;
@property (nonatomic, readwrite) RequestEncodingMIMEType encodingType;
@property (nonatomic, readwrite) RequestType requestType;

@property (nonatomic, weak, readwrite) PGNetworkingManager *manager;

@end

@implementation PGEndpointRequest

- (instancetype)initWithKey:(id)key
                        url:(NSURL *)url
                  bodyClass:(Class)bodyClass
              responseClass:(Class)responseClass
                 errorClass:(Class)errorClass
               encodingType:(RequestEncodingMIMEType)encodingType
                requestType:(RequestType)requestType
{
  self = [super init];
  if (self) {
    self.key = key;
    self.url = url;
    self.bodyClass = bodyClass;
    self.responseClass = responseClass;
    self.errorClass = errorClass;
    self.encodingType = encodingType;
    self.requestType = requestType;

    if (bodyClass) {
      NSString *error = [NSString stringWithFormat:@"%@ request to %@ does not have a valid obbject mapping for class %@",
                         [self stringFromEnum:self.requestType],
                         url.absoluteString,
                         NSStringFromClass(bodyClass)];
      NSAssert([bodyClass conformsToProtocol:@protocol(PGMappableObject)], error);
    }
    if (responseClass) {
      NSString *error = [NSString stringWithFormat:@"%@ request to %@ does not have a valid obbject mapping for class %@",
                         [self stringFromEnum:self.requestType],
                         url.absoluteString,
                         NSStringFromClass(responseClass)];
      NSAssert([responseClass conformsToProtocol:@protocol(PGMappableObject)], error);
    }
    if (errorClass) {
      NSString *error = [NSString stringWithFormat:@"%@ request to %@ does not have a valid obbject mapping for class %@",
                         [self stringFromEnum:self.requestType],
                         url.absoluteString,
                         NSStringFromClass(errorClass)];
      NSAssert([errorClass conformsToProtocol:@protocol(PGMappableObject)], error);
    }
  }

  return self;
}

- (instancetype)initWithEndpoint:(int)endpoint
                             url:(NSURL *)url
                       bodyClass:(Class)bodyClass
                   responseClass:(Class)responseClass
                      errorClass:(Class)errorClass
                    encodingType:(RequestEncodingMIMEType)encodingType
                     requestType:(RequestType)requestType
{
  return [self initWithKey:@(endpoint)
                       url:url
                 bodyClass:bodyClass
             responseClass:responseClass
                errorClass:errorClass
              encodingType:self.manager.encodingType
               requestType:requestType];
}

#pragma mark Networking Manager

- (PGNetworkingManager *)manager
{
  if (!_manager) _manager = [PGNetworkingManager objectManager];
  return _manager;
}

#pragma mark String helpers

- (NSString *)stringFromEnum:(RequestType)type
{
  switch (type) {
    case RequestTypeDELETE:
      return @"DELETE";
      break;
    case RequestTypePOST:
      return @"POST";
      break;
    case RequestTypeGET:
      return @"GET";
      break;
    case RequestTypePUT:
      return @"PUT";
      break;
  }
}

@end
