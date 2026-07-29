//
//  FriendStore.m
//  iOSStudyApp
//

#import "FriendStore.h"

NSNotificationName const FriendDataDidChangeNotification = @"FriendDataDidChangeNotification";

static NSString * const kFriendIdsKey = @"iosstudy.friend.ids";

@interface FriendStore ()
@property (nonatomic, copy) NSArray<NSDictionary *> *catalog;
@property (nonatomic, strong) NSMutableArray<NSString *> *friendIds;
@end

@implementation FriendStore

+ (instancetype)shared {
    static FriendStore *store;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[FriendStore alloc] init];
    });
    return store;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _catalog = [self buildCatalog];
        NSArray *saved = [NSUserDefaults.standardUserDefaults arrayForKey:kFriendIdsKey];
        _friendIds = saved ? [saved mutableCopy] : [NSMutableArray array];
    }
    return self;
}

- (NSArray<NSDictionary *> *)buildCatalog {
    return @[
        @{
            @"id": @"f_xiaoming",
            @"name": @"小明",
            @"totalMinutes": @186,
            @"todayMinutes": @25,
            @"records": @[
                @{@"lessonTitle": @"UITableView 复用与性能", @"studiedAt": @"今天 09:20", @"minutes": @18},
                @{@"lessonTitle": @"GCD 基础与队列", @"studiedAt": @"昨天 21:05", @"minutes": @32},
                @{@"lessonTitle": @"Auto Layout 入门", @"studiedAt": @"前天 20:10", @"minutes": @40},
            ],
        },
        @{
            @"id": @"f_xiaohong",
            @"name": @"小红",
            @"totalMinutes": @312,
            @"todayMinutes": @40,
            @"records": @[
                @{@"lessonTitle": @"网络请求 NSURLSession", @"studiedAt": @"今天 08:15", @"minutes": @40},
                @{@"lessonTitle": @"JSON 解析与模型", @"studiedAt": @"昨天 19:40", @"minutes": @28},
                @{@"lessonTitle": @"MVC 与控制器职责", @"studiedAt": @"周一 22:00", @"minutes": @35},
            ],
        },
        @{
            @"id": @"f_alex",
            @"name": @"Alex",
            @"totalMinutes": @98,
            @"todayMinutes": @12,
            @"records": @[
                @{@"lessonTitle": @"Objective-C 内存管理", @"studiedAt": @"今天 11:00", @"minutes": @12},
                @{@"lessonTitle": @"Block 与循环引用", @"studiedAt": @"周日 16:30", @"minutes": @45},
            ],
        },
        @{
            @"id": @"f_sara",
            @"name": @"Sara",
            @"totalMinutes": @540,
            @"todayMinutes": @55,
            @"records": @[
                @{@"lessonTitle": @"RunLoop 够用指南", @"studiedAt": @"今天 07:50", @"minutes": @30},
                @{@"lessonTitle": @"KVO / KVC 实践", @"studiedAt": @"今天 10:05", @"minutes": @25},
                @{@"lessonTitle": @"异常与崩溃排查", @"studiedAt": @"昨天 18:20", @"minutes": @50},
                @{@"lessonTitle": @"通知中心注意事项", @"studiedAt": @"周二 21:15", @"minutes": @22},
            ],
        },
        @{
            @"id": @"f_lihua",
            @"name": @"李华",
            @"totalMinutes": @75,
            @"todayMinutes": @0,
            @"records": @[
                @{@"lessonTitle": @"UINavigationController 导航", @"studiedAt": @"上周六 15:00", @"minutes": @20},
                @{@"lessonTitle": @"UITabBarController 结构", @"studiedAt": @"上周日 11:30", @"minutes": @18},
            ],
        },
        @{
            @"id": @"f_chenchen",
            @"name": @"晨晨",
            @"totalMinutes": @220,
            @"todayMinutes": @18,
            @"records": @[
                @{@"lessonTitle": @"沙盒与持久化", @"studiedAt": @"今天 13:40", @"minutes": @18},
                @{@"lessonTitle": @"UserDefaults 使用场景", @"studiedAt": @"昨天 20:00", @"minutes": @26},
                @{@"lessonTitle": @"FMDB 基础", @"studiedAt": @"周三 19:10", @"minutes": @44},
            ],
        },
    ];
}

- (NSArray<NSDictionary *> *)allCandidates {
    return self.catalog;
}

- (NSDictionary *)profileForId:(NSString *)friendId {
    for (NSDictionary *item in self.catalog) {
        if ([item[@"id"] isEqualToString:friendId]) {
            return item;
        }
    }
    return nil;
}

- (NSArray<NSDictionary *> *)friends {
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *fid in self.friendIds) {
        NSDictionary *profile = [self profileForId:fid];
        if (profile) {
            [result addObject:profile];
        }
    }
    return result;
}

- (BOOL)isFriend:(NSString *)friendId {
    return [self.friendIds containsObject:friendId];
}

- (BOOL)addFriendWithId:(NSString *)friendId {
    if (friendId.length == 0) return NO;
    if (![self profileForId:friendId]) return NO;
    if ([self isFriend:friendId]) return NO;
    [self.friendIds addObject:friendId];
    [self persist];
    [[NSNotificationCenter defaultCenter] postNotificationName:FriendDataDidChangeNotification object:self];
    return YES;
}

- (void)removeFriendWithId:(NSString *)friendId {
    if (![self isFriend:friendId]) return;
    [self.friendIds removeObject:friendId];
    [self persist];
    [[NSNotificationCenter defaultCenter] postNotificationName:FriendDataDidChangeNotification object:self];
}

- (NSDictionary *)friendWithId:(NSString *)friendId {
    return [self profileForId:friendId];
}

- (NSArray<NSDictionary *> *)candidatesMatchingQuery:(NSString *)query {
    NSString *trimmed = [query stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (trimmed.length == 0) {
        return self.catalog;
    }
    NSMutableArray *matched = [NSMutableArray array];
    for (NSDictionary *item in self.catalog) {
        NSString *name = item[@"name"] ?: @"";
        if ([name rangeOfString:trimmed options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [matched addObject:item];
        }
    }
    return matched;
}

- (void)persist {
    [NSUserDefaults.standardUserDefaults setObject:[self.friendIds copy] forKey:kFriendIdsKey];
}

@end
