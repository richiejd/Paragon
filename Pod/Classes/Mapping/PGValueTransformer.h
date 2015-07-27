//
//  PGValueTransformer.h
//  Pods
//
//  Created by Richie Davis on 7/26/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PGTransformResultType) {
  PGTransformResultTypeBOOL,
  PGTransformResultTypeDouble,
  PGTransformResultTypeFloat,
  PGTransformResultTypeInt,
  PGTransformResultTypeNSInteger,
  PGTransformResultTypeNSUInteger,
  PGTransformResultTypeMAX
};

@interface PGValueTransformer : NSObject

+ (id)transformValue:(id)value toClass:(Class)class;
+ (id)transformValue:(id)value withTransform:(PGTransformResultType)transform;

@end
