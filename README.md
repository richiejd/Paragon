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

## Author

Richie, richiejdavis27@gmail.com

## License

Paragon is available under the MIT license. See the LICENSE file for more info.
