//
//  PGRelationshipMapping.m
//  Pods
//
//  Created by Richie Davis on 7/26/15.
//
//

#import "PGObjectMapping.h"
#import "PGRelationshipMapping.h"

@interface PGRelationshipMapping ()

@property (nonatomic, copy, readwrite) NSString *inboundKey;
@property (nonatomic, copy, readwrite) NSString *propertyName;
@property (nonatomic, strong, readwrite) PGObjectMapping *mapping;

@end

@implementation PGRelationshipMapping

+ (instancetype)relationshipWithKey:(NSString *)inboundKey
                           property:(NSString *)propertyName
                            mapping:(PGObjectMapping *)mapping
{
  PGRelationshipMapping *relationshipMapping = [[PGRelationshipMapping alloc] init];
  if (relationshipMapping) {
    relationshipMapping.inboundKey = inboundKey;
    relationshipMapping.propertyName = propertyName;
    relationshipMapping.mapping = mapping;
  }

  return relationshipMapping;
}

+ (instancetype)relationshipWithProperty:(NSString *)propertyName
                                 mapping:(PGObjectMapping *)mapping
{
  return [self relationshipWithKey:propertyName property:propertyName mapping:mapping];
}

@end
