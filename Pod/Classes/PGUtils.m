//
//  PGUtils.m
//  Pods
//
//  Created by Richie Davis on 7/26/15.
//
//

#import "PGUtils.h"
#import <objc/runtime.h>

@implementation PGUtils

+ (Class)classOfPropertyNamed:(NSString *)propertyName class:(Class)class
{
  // Get Class of property to be populated.
  Class propertyClass;
  objc_property_t property = class_getProperty(class, [propertyName UTF8String]);
  NSString *propertyAttributes = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
  NSArray *splitPropertyAttributes = [propertyAttributes componentsSeparatedByString:@","];
  if (splitPropertyAttributes.count > 0) {
    NSArray *splitEncodeType = [splitPropertyAttributes[0] componentsSeparatedByString:@"\""];
    NSString *error = [NSString stringWithFormat:@"Error trying to map property %@ for class %s, the property %@ does not appear to be of type NSObject, please consider using a transformer if it is a supported PGTransformResultType, otherwise your type is not currently supported.", propertyName, class_getName(class), propertyName];
    NSAssert(splitEncodeType.count > 1, error);
    propertyClass = NSClassFromString(splitEncodeType[1]);
  }
  return propertyClass;
}

@end
