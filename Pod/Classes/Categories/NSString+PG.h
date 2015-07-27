//
//  NSString+PG.h
//  Pods
//
//  Created by Richie Davis on 7/27/15.
//
//

#import <Foundation/Foundation.h>

@interface NSString (PG)

- (BOOL)hasSubstring:(NSString *)substring;
+ (NSString *)stringByAppendingParams:(NSDictionary *)params toUrl:(NSURL *)url;
+ (NSString *)stringByAppendingParams:(NSDictionary *)params toString:(NSString *)url;

@end
