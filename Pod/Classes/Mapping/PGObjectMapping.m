//
//  PGObjectMapping.m
//  Pods
//
//  Created by Richie Davis on 7/26/15.
//
//

#import "PGObjectMapping.h"
#import "PGRelationshipMapping.h"
#import "PGUtils.h"
#import "NSString+PG.h"
#import "NSDictionary+PG.h"
#import <objc/runtime.h>

@interface PGObjectMapping ()

@property (nonatomic, copy) NSDictionary *baseMappings;
@property (nonatomic, copy) NSDictionary *baseTransforms;
@property (nonatomic, copy) NSArray *relationshipMappings;
@property (nonatomic, weak, readwrite) Class mappingClass;

@end

@implementation PGObjectMapping

+ (instancetype)mappingForClass:(Class)modelClass
{
  PGObjectMapping *mapping = [[PGObjectMapping alloc] init];
  mapping.mappingClass = modelClass;
  return mapping;
}

- (void)addPropertyMappingsFromArray:(NSArray *)propertyMappings
{
  [self addPropertyMappingsFromDictionary:[[NSDictionary alloc] initWithObjects:propertyMappings
                                                                        forKeys:propertyMappings]];
}

- (void)addPropertyMappingsFromDictionary:(NSDictionary *)propertyMappings
{
  NSMutableDictionary *newMappings = [[NSMutableDictionary alloc] init];
  NSString *error = [NSString stringWithFormat:@"Your property mappings must be strings, this is violated for class %s", class_getName(self.mappingClass)];
  for (id key in propertyMappings) {
    id val = propertyMappings[key];
    [PGUtils assert:[key isKindOfClass:[NSString class]] message:error];
    [PGUtils assert:[val isKindOfClass:[NSString class]] message:error];
    newMappings[key] = val;
  }

  [newMappings addEntriesFromDictionary:self.baseMappings];
  self.baseMappings = [newMappings copy];
}

- (void)addTransformsFromDictionary:(NSDictionary *)transforms
{
  NSMutableDictionary *newTransforms = [[NSMutableDictionary alloc] init];
  NSString *classError = [NSString stringWithFormat:@"Your property mappings must be strings and your transforms must be NSNumbers, this is violated for class %s", class_getName(self.mappingClass)];
  NSString *valueError = [NSString stringWithFormat:@"Your transforms must be in the set of enum, this is violated for transforms in class %s", class_getName(self.mappingClass)];
  for (id key in transforms) {
    NSNumber *val = transforms[key];
    [PGUtils assert:[key isKindOfClass:[NSString class]] message:classError];
    [PGUtils assert:[val isKindOfClass:[NSNumber class]] message:classError];
    [PGUtils assert:val.intValue >= 0 && val.intValue < PGTransformResultTypeMAX
            message:valueError];
    newTransforms[key] = val;
  }

  [newTransforms addEntriesFromDictionary:self.baseTransforms];
  self.baseTransforms = [newTransforms copy];
}

- (void)addRelationshipMappingsFromArray:(NSArray *)relationshipMappings
{
  NSString *error = [NSString stringWithFormat:@"Your relationship mappings must be PGRelationshipMapping objects, this is violated for class %s", class_getName(self.mappingClass)];
  for (id mapping in relationshipMappings) {
    [PGUtils assert:[mapping isKindOfClass:[PGRelationshipMapping class]] message:error];
  }
  self.relationshipMappings = [relationshipMappings arrayByAddingObjectsFromArray:self.relationshipMappings];
}

- (id)objectFromDictionary:(NSDictionary *)dictionary
{
  if (!dictionary) return nil;

  id result = [[self.mappingClass alloc] init];

  // start with base mapping
  for (NSString *key in self.baseMappings) {
    NSArray *splitKey = [key componentsSeparatedByString:@"."];
    id propertyObject;
    if (splitKey.count > 1 && dictionary[splitKey[0]]) {
      int idx = 1;
      propertyObject = dictionary[splitKey[0]];
      while (propertyObject && idx < splitKey.count) {
        if ([propertyObject isKindOfClass:[NSDictionary class]] || idx == splitKey.count - 1) {
          propertyObject = [(NSDictionary *)propertyObject objectForKey:splitKey[idx]];
        } else {
          // we bail, if not the last idx, we require another dictionary in this case and it was not present
          propertyObject = nil;
        }
        idx++;
      }
    } else if (dictionary[splitKey[0]]) {
      propertyObject = dictionary[splitKey[0]];
    }

    if (self.baseTransforms[key]) {
      PGTransformResultType type = ((NSNumber *)self.baseTransforms[key]).integerValue;
      propertyObject = [PGValueTransformer transformValue:propertyObject withTransform:type];
    } else {
      if ([propertyObject isKindOfClass:[NSNull class]]) propertyObject = nil;

      if (propertyObject) {
        Class propertyClass = [PGUtils classOfPropertyNamed:self.baseMappings[key] class:self.mappingClass];
        propertyObject = [PGValueTransformer transformValue:propertyObject toClass:propertyClass];
        BOOL classMatch = [propertyObject isKindOfClass:propertyClass];
        NSString *error = [NSString stringWithFormat:@"mapping for %s on the key %@ failed due to a type mismatch", class_getName(self.mappingClass), self.baseMappings[key]];
        [PGUtils assert:classMatch message:error];
        BOOL objectHasClass = [(id)result respondsToSelector:NSSelectorFromString(self.baseMappings[key])];
        error = [NSString stringWithFormat:@"mapping for %s failed due to missing property %@", class_getName(self.mappingClass), self.baseMappings[key]];
        [PGUtils assert:objectHasClass message:error];
      }
    }

    [result setValue:propertyObject forKey:self.baseMappings[key]];
  }

  // now handle the relationship mapping
  for (PGRelationshipMapping *mapping in self.relationshipMappings) {
    NSArray *splitKey = [mapping.inboundKey componentsSeparatedByString:@"."];
    id propertyObject;
    if (splitKey.count > 1 && dictionary[splitKey[0]]) {
      int idx = 1;
      propertyObject = dictionary[splitKey[0]];
      while (propertyObject && idx < splitKey.count) {
        if ([propertyObject isKindOfClass:[NSDictionary class]]) {
          propertyObject = [(NSDictionary *)propertyObject objectForKey:splitKey[idx]];
        } else {
          // we bail, for relationship mappings we require a dictionary
          propertyObject = nil;
        }
        idx++;
      }
    } else if (dictionary[splitKey[0]]) {
      propertyObject = dictionary[splitKey[0]];
    }

    if (propertyObject && ![propertyObject isKindOfClass:[NSNull class]]) {
      if ([propertyObject isKindOfClass:[NSArray class]]) {
        NSMutableArray *newObject = [[NSMutableArray alloc] init];
        for (id obj in propertyObject) {
          [newObject addObject:[mapping.mapping objectFromDictionary:obj]];
        }
        propertyObject = newObject;
      } else {
        propertyObject = [mapping.mapping objectFromDictionary:propertyObject];
      }
      Class propertyClass = [PGUtils classOfPropertyNamed:mapping.propertyName class:self.mappingClass];
      BOOL classMatch = [propertyObject isKindOfClass:propertyClass];
      NSString *error = [NSString stringWithFormat:@"mapping for %s on the key %@ failed due to a type mismatch", class_getName(self.mappingClass), mapping.propertyName];
      [PGUtils assert:classMatch message:error];
      BOOL objectHasClass = [(id)result respondsToSelector:NSSelectorFromString(mapping.propertyName)];
      error = [NSString stringWithFormat:@"mapping for %s failed due to missing property %@", class_getName(self.mappingClass), mapping.propertyName];
      [PGUtils assert:objectHasClass message:error];
    }
    [result setValue:propertyObject forKey:mapping.propertyName];
  }

  return result;
}

- (NSDictionary *)dictionaryFromObject:(id)object
{
  if (!object) return nil;

  NSMutableDictionary *result = [[NSMutableDictionary alloc] init];

  // start with base mapping
  for (NSString *key in self.baseMappings) {
    NSString *error = [NSString stringWithFormat:@"mapping for %s failed, this class has no property %@", class_getName(self.mappingClass), self.baseMappings[key]];
    [PGUtils assert:[object respondsToSelector:NSSelectorFromString(self.baseMappings[key])] message:error];

    id propertyObject = [object propertyForKey:self.baseMappings[key]];
    propertyObject = propertyObject ? propertyObject : [NSNull null];

    NSArray *splitKey = [key componentsSeparatedByString:@"."];
    if (splitKey.count > 1) {
      NSDictionary *generatedDictionary = [NSDictionary dictionaryFromKeyArray:splitKey finalObject:propertyObject];
      result = [[result mergeWithDictionary:generatedDictionary] mutableCopy];
    } else {
      result[key] = propertyObject;
    }
  }

  // now handle relationship mappings
  for (PGRelationshipMapping *mapping in self.relationshipMappings) {
    NSString *error = [NSString stringWithFormat:@"mapping for %s failed, this class has no property %@", class_getName(self.mappingClass), mapping.propertyName];
    [PGUtils assert:[object respondsToSelector:NSSelectorFromString(mapping.propertyName)] message:error];

    id propertyObject = [object propertyForKey:mapping.propertyName];
    propertyObject = propertyObject ? propertyObject : [NSNull null];

    NSArray *splitKey = [mapping.inboundKey componentsSeparatedByString:@"."];
    if (splitKey.count > 1) {
      NSDictionary *generatedDictionary = [NSDictionary dictionaryFromKeyArray:splitKey finalObject:propertyObject];
      result = [[result mergeWithDictionary:generatedDictionary] mutableCopy];
    } else {
      result[mapping.inboundKey] = propertyObject;
    }
  }
  
  return result;
}

@end
