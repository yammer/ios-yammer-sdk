//
//  YMGroup.h
//  Pods
//
//  Created by Peter Willsey on 6/3/15.
//
//

#import <Foundation/Foundation.h>
#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>

@interface YMGroup : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong, readonly) NSDate *createdAt;
@property (nonatomic, assign, readonly) NSUInteger creatorID;
@property (nonatomic, copy, readonly) NSString *creatorType;
@property (nonatomic, copy, readonly) NSString *groupDescription;
@property (nonatomic, copy, readonly) NSString *fullName;
@property (nonatomic, assign, readonly) NSUInteger groupID;
@property (nonatomic, copy, readonly) NSString *mugshotID;
@property (nonatomic, strong, readonly) NSURL *mugshotURL;
@property (nonatomic, copy, readonly) NSString *mugshotURLTemplate;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) NSUInteger networkID;
@property (nonatomic, strong, readonly) NSURL *office365URL;
@property (nonatomic, copy, readonly) NSString *privacy;
@property (nonatomic, assign, readonly) BOOL showInDirectory;
@property (nonatomic, copy, readonly) NSString *state;
@property (nonatomic, strong, readonly) NSDate *lastMessageAt;
@property (nonatomic, assign, readonly) NSUInteger lastMessageID;
@property (nonatomic, assign, readonly) NSUInteger members;
@property (nonatomic, assign, readonly) NSUInteger updates;
@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, strong, readonly) NSURL *webURL;

- (id)objectForKeyedSubscript:(NSString *)key;

@end
