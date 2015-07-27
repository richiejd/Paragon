//
//  NSDictionary+PG.m
//  Pods
//
//  Created by Richie Davis on 7/27/15.
//
//

#import "NSDictionary+PG.h"

@implementation NSDictionary (PG)

// assumes that keys are strings
// if both dictionaries have a key, if the corresponding
// value is a dictionary then it will continue the merge
// otherwise it uses the existing value
- (NSDictionary *)mergeWithDictionary:(NSDictionary *)dict
{
  NSMutableDictionary *newDict = [self mutableCopy];
  for (id key1 in dict) {
    BOOL found = NO;
    for (id key2 in self) {
      if ([key1 isEqualToString:key2]) {
        found = YES;
        if ([self[key2] isKindOfClass:[NSDictionary class]] && [dict[key1] isKindOfClass:[NSDictionary class]]) {
          NSDictionary *currentDict = self[key2];
          NSDictionary *mergeDict = dict[key1];
          newDict[key2] = [currentDict mergeWithDictionary:mergeDict];
        }
      }
    }
    if (!found) newDict[key1] = dict[key1];
  }

  return [newDict copy];
}

// creates a nested dictionary with the given keys and places an object as the final value
+ (NSDictionary *)dictionaryFromKeyArray:(NSArray *)keyArray finalObject:(id)object
{
  if (!keyArray || keyArray.count == 0) return nil;
  NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{keyArray[0] : @""}];
  for (int i = 1; i <= keyArray.count; i++) {
    NSMutableDictionary *currentDict = dict;
    for (int j = 1; j < i; j++) {
      currentDict = currentDict[keyArray[j]];
    }
    if (i == keyArray.count) {
      currentDict[keyArray[i-1]] = object;
    } else {
      currentDict[keyArray[i-1]] = [[NSMutableDictionary alloc] initWithDictionary:@{keyArray[i] : @""}];
    }
  }

  return dict;
}

@end
