# Paragon

[![CI Status](http://img.shields.io/travis/Richie/Paragon.svg?style=flat)](https://travis-ci.org/Richie/Paragon)
[![Version](https://img.shields.io/cocoapods/v/Paragon.svg?style=flat)](http://cocoapods.org/pods/Paragon)
[![License](https://img.shields.io/cocoapods/l/Paragon.svg?style=flat)](http://cocoapods.org/pods/Paragon)
[![Platform](https://img.shields.io/cocoapods/p/Paragon.svg?style=flat)](http://cocoapods.org/pods/Paragon)

## Installation

Paragon is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Paragon"
```

## Integration and usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Mapping

Use this pod to map objects to and from json. All of the mapping methods  
can be found within the [PGObjectMapping](https://github.com/Javier27/Paragon/blob/master/Pod/Classes/Mapping/PGObjectMapping.h) class  

Create an instance of model mapping as such
```objc
+ (instancetype)mappingForClass:(Class)modelClass;
```  

Then use the following four methods to define the mapping:  
```objc
- (void)addPropertyMappingsFromArray:(NSArray *)propertyMappings;
- (void)addPropertyMappingsFromDictionary:(NSDictionary *)propertyMappings;
- (void)addTransformsFromDictionary:(NSDictionary *)transforms;
- (void)addRelationshipMappingsFromArray:(NSArray *)relationshipMappings;
```  

You will note that relationshipMappings have two initializers, one when your  
payload key matches the property name and one when it does not, these are the two:  
```objc
+ (instancetype)relationshipWithKey:(NSString *)inboundKey
                           property:(NSString *)propertyName
                            mapping:(PGObjectMapping *)mapping;

+ (instancetype)relationshipWithProperty:(NSString *)propertyName
                                 mapping:(PGObjectMapping *)mapping;
```

#### Examples of mappings: each of these will have json and the corresponding classes to consume them in a mapping

I will leave out parts of the class and only show what is necessary for demonstration  
You will need to import classes, etc. to have this compile

Modeling a set of pet owners and their pets within a given state

```json
{
  "owners" : [
    {
      "name" : "Javier",
      "num_pets" : 1,
      "is_homeowner" : true,
      "pets" : [
        {
          "name" : "Joey",
          "type_id" : null,
          "type_code" : "cat"
        }
      ]
    }
  ],
  "count" : 10,
  "region_code" : "OH",
  "country_code" : "US",
  "name" : "Ohio"
}
```

The overall payload we will say is a pet owner region, we will define a class
```objc
@interface PetOwnerRegion : NSObject <PGMappableObject>

@property (nonatomic, copy) NSArray *owners; // array of PetOwner
@property (nonatomic, copy) NSString *regionCode;
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSUInteger ownerCount;

@end
```

Then the class will have the following method implementation (as per the PGMappableObject protocol)  
```objc
+ (PGObjectMapping *)mapping
{
  PGObjectMapping *mapping = [PGObjectMapping mappingForClass:self];
  [mapping addPropertyMappingsFromArray:@[@"name"]]; // note name could be in the next submission as @"name" : @"name"

  [mapping addPropertyMappingsFromDictionary:@{@"region_code" : @"regionCode",
                                               @"country_code" : @"countryCode",
                                               @"count" : @"ownerCount"}];

  // this is required because we are mapping into a non-object (NSUInteger)
  [mapping addTransformsFromDictionary:@{@"count" : @(PGTransformResultTypeNSUInteger)}];

  // the PetOwner mapping will be applied to each element of the array
  [mapping addRelationshipMappingsFromArray:@[
    [PGRelationshipMapping relationshipWithProperty:@"owners" mapping:[PetOwner mapping]]
  ]];

return mapping;
}
```

Then we will need the following class (as used in the above)  
```objc
@interface PetOwner : NSObject <PGMappableObject>

@property (nonatomic, copy) NSArray *pets; // array of Pet
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSUInteger petCount;
@property (nonatomic) BOOL isHomeowner;

@end
```

Then the class will have the following method implementation (as per the PGMappableObject protocol)  
```objc
+ (PGObjectMapping *)mapping
{
  PGObjectMapping *mapping = [PGObjectMapping mappingForClass:self];
  [mapping addPropertyMappingsFromArray:@[@"name"]];

  [mapping addPropertyMappingsFromDictionary:@{@"num_pets" : @"petCount",
                                               @"is_homeowner" : @"isHomeowner"}];

  [mapping addTransformsFromDictionary:@{@"num_pets" : @(PGTransformResultTypeNSUInteger),
                                         @"is_homeowner" : @(PGTransformResultTypeBOOL)}];

  // the PetOwner mapping will be applied to each element of the array
  [mapping addRelationshipMappingsFromArray:@[
    [PGRelationshipMapping relationshipWithProperty:@"pets" mapping:[Pet mapping]]
  ]];

  return mapping;
}
```

and finally, we have the mapping for Pet  
```objc
@interface PetOwner : NSObject <PGMappableObject>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *typeCode;
@property (nonatomic, strong) NSNumber *typeId; // we use NSNumber here because it can be null

@end
```

Then the class will have the following method implementation (as per the PGMappableObject protocol)  
```objc
+ (PGObjectMapping *)mapping
{
  PGObjectMapping *mapping = [PGObjectMapping mappingForClass:self];
  [mapping addPropertyMappingsFromArray:@[@"name"]];

  [mapping addPropertyMappingsFromDictionary:@{@"type_id" : @"typeId",
                                               @"type_code" : @"typeCode"}];

  return mapping;
}
```

Now that you've created to mapping you can use it!  

To get a dictionary from a model let's assume we have an instance of PetOwnerRegion  
called region, to get a dictionary from the object simply call
```objc
NSDictionary *objDictionary = [[PetOwnerRegion mapping] dictionaryFromObject:region];
```

and likewise, if we have a dictionary we can call the following to get an instance
```objc
PetOwnerRegion *region = [[PetOwnerRegion mapping] objectFromDictionary:dictionary];
```

### Networking layer

If you want to fully harness the power of Paragon, then the networking layer is huge.  
Paragon is designed to work when used correctly and when utilizing best practices with  
the library you'll find yourself with a clean networking layer

You should subclass ```PGAPIClient``` and make sure to populate ```PGNetworkingManager```  
with any request you want to have neatly laid into your application.

#### PGAPIClient

This class is designed to be the go-between for your application and whatever web APIs you  
rely on as well as each view controller and the APIs they inevitably need data from. Feel  
free to use this in your application however it suits you best, but as a good practice it's  
a good idea to let each view controller have it's own client and to let your application to  
have a client as well. Here is an example implementation of an APIClient at a basic level:

```objc
#import "PGAPIClient.h"

@interface ExampleAPIClient : PGAPIClient

- (void)getItemWithId:(NSNumber *)itemId completion:(PGCompletion)completion;

@end



#import "ExampleAPIClient.h"
#import "ExampleRequestManager.h"

@implementation ExampleAPIClient

- (void)getItemWithId:(NSNumber *)itemId completion:(PGCompletion)completion
{
  [self performRequestWithEndpoint:@(ExampleEndpointGetItem)
                        pathSuffix:[itemId stringValue]
                        completion:completion];
}

- (NSDictionary *)headersForRequest:(PGEndpointRequest *)request
{
  // custom handle headers for each request, then if you want to use
  // the default headers in your networking manager, use
  [super headersForRequest:request];
}

@end
```

#### Networking Manager

Then you need to setup your networking manager, an example of how to do this would be  
to create a request manager such as the following:
```objc
#import <Foundation/Foundation.h>

// create an enum with all of the request keys, this is nice organizationally
typedef enum : NSInteger {
  ExampleEndpointGetItem
} ExampleEndpoint;

@interface ExampleRequestManager : NSObject

+ (void)assignManagerFields;
+ (void)setupEndpointRequests;

@end



#import "ExampleRequestManager.h"
#import "PGNetworkingManager.h"
#import "CustomError.h"
#import "Item.h"

@implementation ExampleRequestManager

// these are the default fields that will go with requests
+ (void)assignManagerFields
{
  [PGNetworkingManager setupWithBaseUrl:[NSURL URLWithString:@"https://api.example.com"]
                             errorClass:[CustomError class]
                           encodingType:RequestEncodingMIMETypeForm
                                headers:@{}];
}

// add all of your endpoints here
+ (void)setupEndpointRequests
{
  [PGNetworkingManager storeEndpoints:@[
    GET(@(ExampleEndpointGetItem), [Item class], @"/items/")]
  ];
}

@end
```

Then in your app setup you'd need to call
```objc
[ExampleRequestManager assignManagerFields];
[ExampleRequestManager setupEndpointRequests];
```

To utilize this from a view controller, if you have setup some BaseViewController  
(so that all of your view controllers have this by default)  with  
```objc
@property (nonatomic, strong) ExampleAPIClient *apiClient;
```

then to make your request you can simply call:
```objc
[self.apiClient getItemWithId:@(59) completion:^(id response, id error) {
  if (response) {
    // handle response however you'd like
  } else if (error) {
    // handle error however you'd like
  } else {
    // do whatever you'd like
  {
}];
```

Simple! It's worth noting that if you want your callbacks to have a more specific type than  
(id response, id error) or (NSInteger statusCode, id response, id error) then in your APIClient  
you can make your enddpoints something like

```objc
- (void)getItemWithId:(NSNumber *)itemId completion:(void(^)(Item *response, CustomError *error))completion;
```



## Author

Richie, richiejdavis27@gmail.com

## License

Paragon is available under the MIT license. See the LICENSE file for more info.
