//
//  PGRelationshipMapping.h
//  Pods
//
//  Created by Richie Davis on 7/26/15.
//
//

#import <Foundation/Foundation.h>
@class PGObjectMapping;

@interface PGRelationshipMapping : NSObject

@property (nonatomic, copy, readonly) NSString *inboundKey;
@property (nonatomic, copy, readonly) NSString *propertyName;
@property (nonatomic, strong, readonly) PGObjectMapping *mapping;

+ (instancetype)relationshipWithKey:(NSString *)inboundKey
                           property:(NSString *)propertyName
                            mapping:(PGObjectMapping *)mapping;

+ (instancetype)relationshipWithProperty:(NSString *)propertyName
                                 mapping:(PGObjectMapping *)mapping;

@end
