//
//  FriendStore.h
//  iOSStudyApp
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSNotificationName const FriendDataDidChangeNotification;

@interface FriendStore : NSObject

+ (instancetype)shared;

/// All local mock candidates that can be added.
- (NSArray<NSDictionary *> *)allCandidates;

/// Currently added friends (persisted).
- (NSArray<NSDictionary *> *)friends;

- (BOOL)isFriend:(NSString *)friendId;

/// Returns YES if newly added; NO if already friend or unknown id.
- (BOOL)addFriendWithId:(NSString *)friendId;

- (void)removeFriendWithId:(NSString *)friendId;

- (nullable NSDictionary *)friendWithId:(NSString *)friendId;

/// Candidates matching keyword in name (case-insensitive). Empty keyword returns all non-friends preferred, or all.
- (NSArray<NSDictionary *> *)candidatesMatchingQuery:(NSString *)query;

@end

NS_ASSUME_NONNULL_END
