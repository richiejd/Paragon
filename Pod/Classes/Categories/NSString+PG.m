//
//  NSString+PG.m
//  Pods
//
//  Created by Richie Davis on 7/27/15.
//
//

#import "NSString+PG.h"

@implementation NSString (PG)

- (BOOL)hasSubstring:(NSString *)substring
{
  return [self rangeOfString:substring].location == NSNotFound;
}

+ (NSString *)stringByAppendingParams:(NSDictionary *)params toUrl:(NSURL *)url
{
  NSURLComponents *components = [[NSURLComponents alloc] initWithString:url.absoluteString];
  NSMutableString *addedQueryString = [[NSMutableString alloc] init];
  for (NSString *key in params) {
    NSString *value = params[key];
    if (addedQueryString.length > 0) [addedQueryString appendString:@"&"];
    [addedQueryString appendString:[NSString stringWithFormat:@"%@=%@", key, value]];
  }

  if (components.query) {
    [addedQueryString appendString:@"&"];
    [addedQueryString appendString:components.query];
  }

  components.query = addedQueryString;
  return [components URL].absoluteString;
}

+ (NSString *)stringByAppendingParams:(NSDictionary *)params toString:(NSString *)url
{
  return [self stringByAppendingParams:params toUrl:[NSURL URLWithString:url]];
}

@end
