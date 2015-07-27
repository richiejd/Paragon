//
//  NSDictionary+PG.h
//  Pods
//
//  Created by Richie Davis on 7/27/15.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (PG)

- (NSDictionary *)mergeWithDictionary:(NSDictionary *)dictionary;
+ (NSDictionary *)dictionaryFromKeyArray:(NSArray *)keyArray finalObject:(id)object;

@end
