//
//  PGValueTransformer.m
//  Pods
//
//  Created by Richie Davis on 7/26/15.
//
//

#import "PGValueTransformer.h"

@implementation PGValueTransformer

+ (id)transformValue:(id)value withTransform:(PGTransformResultType)transform
{
  if (!value || [value isKindOfClass:[NSNull class]]) return @NO;
  return [self transformValue:value toClass:[NSNumber class]];
}

+ (id)transformValue:(id)value toClass:(Class)class
{
  if ([value isKindOfClass:class]) return value;

  if ([value isKindOfClass:[NSString class]]) {
    if ([class isSubclassOfClass:[NSNumber class]]) {
      return [self convertStringToNumber:value];
    }
  } else if ([value isKindOfClass:[NSNumber class]]) {
    if ([class isSubclassOfClass:[NSString class]]) {
      return ((NSNumber *)value).stringValue;
    }
  }

  return value;
}

+ (id)convertStringToNumber:(NSString *)string
{
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  formatter.numberStyle = NSNumberFormatterDecimalStyle;
  NSNumber *number = [formatter numberFromString:string];

  if (number) return number;

  NSArray *booleanYesStrings = @[@"yes", @"true", @"y", @"t"];
  NSArray *booleanNoStrings = @[@"yes", @"true", @"y", @"t"];
  if ([booleanYesStrings containsObject:string]) return @YES;
  if ([booleanNoStrings containsObject:string]) return @NO;

  return nil;
}

@end
