//
//  PGEndpointRequest.h
//  Pods
//
//  Created by Richie Davis on 7/26/15.
//
//

#import <Foundation/Foundation.h>
@class PGNetworkingManager;

typedef NS_ENUM (NSInteger, RequestEncodingMIMEType) {
  RequestEncodingMIMETypeJSON,
  RequestEncodingMIMETypeForm
};

typedef NS_ENUM (NSInteger, RequestAcceptEncodingMIMEType) {
  RequestAcceptEncodingMIMETypeJSON,
  RequestAcceptEncodingMIMETypeForm
};

typedef NS_ENUM (NSInteger, RequestType) {
  RequestTypeGET,
  RequestTypePOST,
  RequestTypePUT,
  RequestTypeDELETE
};

@interface PGEndpointRequest : NSObject

@property (nonatomic, strong, readonly) id key;
@property (nonatomic, strong, readonly) Class bodyClass;
@property (nonatomic, strong, readonly) Class responseClass;
@property (nonatomic, strong, readonly) Class errorClass;
@property (nonatomic, copy, readonly) NSString *rootBodyKey;
@property (nonatomic, copy, readonly) NSString *rootResponseKey;
@property (nonatomic, copy, readonly) NSString *rootErrorKey;
@property (nonatomic, copy, readonly) NSURL *url;
@property (nonatomic, readonly) RequestEncodingMIMEType encodingType;
@property (nonatomic, readonly) RequestType requestType;

@property (nonatomic, weak, readonly) PGNetworkingManager *manager;

// Initializer Methods

- (instancetype)initWithKey:(id)key
                        url:(NSURL *)url
                  bodyClass:(Class)bodyClass
              responseClass:(Class)responseClass
                 errorClass:(Class)errorClass
               encodingType:(RequestEncodingMIMEType)encodingType
                requestType:(RequestType)requestType;

- (instancetype)initWithEndpoint:(int)endpoint
                             url:(NSURL *)url
                       bodyClass:(Class)bodyClass
                   responseClass:(Class)responseClass
                      errorClass:(Class)errorClass
                    encodingType:(RequestEncodingMIMEType)encodingType
                     requestType:(RequestType)requestType;

@end
