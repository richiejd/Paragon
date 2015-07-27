//
//  PGObjectMapping.h
//  Pods
//
//  Created by Richie Davis on 7/26/15.
//
//

#import <Foundation/Foundation.h>
#import "PGValueTransformer.h"

@interface PGObjectMapping : NSObject

@property (nonatomic, weak, readonly) Class mappingClass;

// alloc inits the mapping
+ (instancetype)mappingForClass:(Class)modelClass;

// adds mapping properties from an array @[@"image", @"code", @"price"]
- (void)addPropertyMappingsFromArray:(NSArray *)propertyMappings;

// adds mapping properties from a dictionary @{@"key_code" : @"code", @"time_hop" : @"timeHop"}
- (void)addPropertyMappingsFromDictionary:(NSDictionary *)propertyMappings;

// adds transforms from a dictionary, wrap the transforms in NSNumber
// @{@"key_code" : @(PGTransformResultTypeChar)}
- (void)addTransformsFromDictionary:(NSDictionary *)transforms;

// adds relationship maps from the array (map representing key,pair value + mapping)
- (void)addRelationshipMappingsFromArray:(NSArray *)relationshipMappings;

// returns an instance object from a dictionary of values corresponding to the mapping
- (id)objectFromDictionary:(NSDictionary *)dictionary;

// returns a dictionary from an object
- (NSDictionary *)dictionaryFromObject:(id)object;

@end
