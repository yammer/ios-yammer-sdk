//
//  YMGroup.m
//  Pods
//
//  Created by Peter Willsey on 6/3/15.
//
//

#import "YMGroup.h"
#import <Mantle/MTLValueTransformer.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>

@implementation YMGroup

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm:ss Z ";
    return dateFormatter;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"createdAt"           : @"created_at",
             @"creatorID"           : @"creator_id",
             @"creatorType"         : @"creator_type",
             @"groupDescription"    : @"description",
             @"fullName"            : @"full_name",
             @"groupID"             : @"id",
             @"mugshotID"           : @"mugshot_id",
             @"mugshotURL"          : @"mugshot_url",
             @"mugshotURLTemplate"  : @"mugshot_url_template",
             @"name"                : @"name",
             @"networkID"           : @"network_id",
             @"office365URL"        : @"office365_url",
             @"privacy"             : @"privacy",
             @"showInDirectory"     : @"show_in_directory",
             @"state"               : @"state",
             @"lastMessageAt"       : @"stats.last_message_at",
             @"lastMessageID"       : @"stats.last_message_id",
             @"members"             : @"stats.members",
             @"updates"             : @"stats.updates",
             @"URL"                 : @"url",
             @"webURL"              : @"web_url"
             };
}

+ (NSValueTransformer *)standardDateJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:value];
    } reverseBlock:^id(NSDate *value, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:value];
    }];
}

+ (NSValueTransformer *)createdAtJSONTransformer
{
    return [self.class standardDateJSONTransformer];
}

+ (NSValueTransformer *)mugshotURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)office365URLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)showInDirectoryJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSString class]]) {
            return ([value isEqualToString:@"true"]) ? @YES : @NO;
        } else {
            *success = NO;
            return nil;
        }
    } reverseBlock:^id(NSNumber *value, BOOL *success, NSError *__autoreleasing *error) {
        return ([value boolValue]) ? @"true" : @"false";
    }];
}

+ (NSValueTransformer *)lastMessageAtJSONTransformer
{
    return [self.class standardDateJSONTransformer];
}

+ (NSValueTransformer *)URLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)webURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
