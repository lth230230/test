//
//  StudyDataStore.m
//  iOSStudyApp
//

#import "StudyDataStore.h"

NSNotificationName const StudyDataDidChangeNotification = @"StudyDataDidChangeNotification";

static NSString * const kCompletedKey = @"my.completedLessons";
static NSString * const kBookmarksKey = @"my.bookmarkedLessons";
static NSString * const kLastLessonKey = @"my.lastLessonId";
static NSString * const kTotalMinutesKey = @"my.totalStudyMinutes";
static NSString * const kTodayMinutesKey = @"my.todayStudyMinutes";
static NSString * const kTodayDateKey = @"my.todayDate";
static NSString * const kStreakKey = @"my.streakDays";
static NSString * const kLastStudyDateKey = @"my.lastStudyDate";
static NSString * const kUserNameKey = @"my.userName";
static NSString * const kDailyGoalKey = @"my.dailyGoalMinutes";
static NSString * const kReminderKey = @"my.reminderEnabled";

@interface StudyDataStore ()
@property (nonatomic, strong) NSArray<NSDictionary *> *lessons;
@property (nonatomic, strong) NSMutableSet<NSString *> *completedIds;
@property (nonatomic, strong) NSMutableSet<NSString *> *bookmarkIds;
@end

@implementation StudyDataStore

+ (instancetype)shared {
    static StudyDataStore *store;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[StudyDataStore alloc] init];
    });
    return store;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self buildCatalog];
        [self loadPersistedState];
        [self refreshTodayIfNeeded];
    }
    return self;
}

#pragma mark - Catalog

- (void)buildCatalog {
    NSArray *loaded = [self loadLessonsFromBundle];
    if (loaded.count > 0) {
        self.lessons = loaded;
        return;
    }
    // Fallback if JSON missing from bundle
    self.lessons = @[
        @{@"id": @"oc-basics", @"title": @"Objective-C 基础语法", @"desc": @"请将 lessons.json 加入 Copy Bundle Resources",
          @"time": @"60分钟", @"minutes": @60, @"tag": @"入门", @"category": @"syntax",
          @"content": @"教材文件未打包进 App。请确认 iOSStudyApp/Resources/lessons.json 已加入 Target 的 Copy Bundle Resources。"}
    ];
}

- (NSArray<NSDictionary *> *)loadLessonsFromBundle {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"lessons" withExtension:@"json"];
    if (!url) return @[];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) return @[];
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error || ![obj isKindOfClass:NSDictionary.class]) return @[];
    NSArray *raw = obj[@"lessons"];
    if (![raw isKindOfClass:NSArray.class]) return @[];
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:raw.count];
    for (NSDictionary *item in raw) {
        if (![item isKindOfClass:NSDictionary.class]) continue;
        NSMutableDictionary *lesson = [item mutableCopy];
        if (![lesson[@"content"] isKindOfClass:NSString.class] || ![lesson[@"content"] length]) {
            lesson[@"content"] = [self composeContentFromLesson:item];
        }
        if (![lesson[@"minutes"] isKindOfClass:NSNumber.class]) {
            NSString *time = [NSString stringWithFormat:@"%@", lesson[@"time"] ?: @"30分钟"];
            NSInteger mins = time.integerValue;
            lesson[@"minutes"] = @(mins > 0 ? mins : 30);
        }
        [result addObject:[lesson copy]];
    }
    return result;
}

- (NSString *)composeContentFromLesson:(NSDictionary *)lesson {
    NSMutableString *text = [NSMutableString string];
    NSArray *goals = lesson[@"learningGoals"];
    if ([goals isKindOfClass:NSArray.class] && goals.count) {
        [text appendString:@"【学习目标】\n"];
        [goals enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [text appendFormat:@"%lu. %@\n", (unsigned long)idx + 1, obj];
        }];
        [text appendString:@"\n"];
    }
    NSArray *prereq = lesson[@"prerequisites"];
    if ([prereq isKindOfClass:NSArray.class] && prereq.count) {
        [text appendString:@"【前置要求】\n"];
        for (id p in prereq) [text appendFormat:@"• %@\n", p];
        [text appendString:@"\n"];
    }
    NSArray *path = lesson[@"learningPath"];
    if ([path isKindOfClass:NSArray.class] && path.count) {
        [text appendString:@"【学习路径】\n"];
        [path enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [text appendFormat:@"Step %lu  %@\n", (unsigned long)idx + 1, obj];
        }];
        [text appendString:@"\n"];
    }
    NSArray *chapters = lesson[@"chapters"];
    if ([chapters isKindOfClass:NSArray.class]) {
        for (NSDictionary *ch in chapters) {
            if (![ch isKindOfClass:NSDictionary.class]) continue;
            [text appendFormat:@"%@\n\n%@\n\n", ch[@"title"] ?: @"", ch[@"body"] ?: @""];
        }
    }
    return text;
}

- (NSArray<NSDictionary *> *)allLessons {
    return self.lessons;
}

- (NSArray<NSDictionary *> *)dailyRecommend {
    return [self.lessons subarrayWithRange:NSMakeRange(0, MIN(8, self.lessons.count))];
}

- (NSArray<NSDictionary *> *)categories {
    return @[
        @{@"id": @"syntax", @"icon": @"textformat.abc", @"title": @"语法基础", @"color": @"teal"},
        @{@"id": @"uikit", @"icon": @"rectangle.3.group", @"title": @"UIKit", @"color": @"coral"},
        @{@"id": @"network", @"icon": @"network", @"title": @"网络编程", @"color": @"green"},
        @{@"id": @"storage", @"icon": @"cylinder.split.1x2", @"title": @"数据持久化", @"color": @"amber"},
        @{@"id": @"concurrency", @"icon": @"arrow.triangle.branch", @"title": @"多线程", @"color": @"slate"},
        @{@"id": @"security", @"icon": @"lock.shield", @"title": @"安全与上架", @"color": @"ocean"},
    ];
}

- (NSArray<NSDictionary *> *)hotCourses {
    NSArray *ids = @[@"autolayout", @"perf", @"gcd"];
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *lid in ids) {
        NSDictionary *lesson = [self lessonWithId:lid];
        if (lesson) [result addObject:lesson];
    }
    return result;
}

- (NSArray<NSDictionary *> *)lessonsForCategory:(NSString *)categoryId {
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *lesson in self.lessons) {
        if ([lesson[@"category"] isEqualToString:categoryId]) {
            [result addObject:lesson];
        }
    }
    return result;
}

- (NSDictionary *)lessonWithId:(NSString *)lessonId {
    for (NSDictionary *lesson in self.lessons) {
        if ([lesson[@"id"] isEqualToString:lessonId]) return lesson;
    }
    return nil;
}

- (NSArray<NSArray<NSDictionary *> *> *)resourceSections {
    return @[
        @[
            @{@"id": @"apple-docs", @"icon": @"doc.text.fill", @"title": @"官方文档",
              @"detail": @"Apple Developer Documentation",
              @"summary": @"涵盖 UIKit、Foundation、Swift、Xcode 等权威资料，建议作为第一手参考。",
              @"url": @"https://developer.apple.com/documentation/"},
            @{@"id": @"books", @"icon": @"book.fill", @"title": @"推荐书籍",
              @"detail": @"《Effective Objective-C》等",
              @"summary": @"系统学习语言惯用法、内存模型与高质量代码组织方式。",
              @"url": @"https://www.objc.io/"},
            @{@"id": @"wwdc", @"icon": @"play.rectangle.fill", @"title": @"视频教程",
              @"detail": @"WWDC 精选视频",
              @"summary": @"每年 WWDC Session 是跟进系统能力与最佳实践的最快路径。",
              @"url": @"https://developer.apple.com/videos/"},
        ],
        @[
            @{@"id": @"tools", @"icon": @"hammer.fill", @"title": @"开发工具",
              @"detail": @"Xcode、Instruments、Reveal",
              @"summary": @"用好调试与性能工具，比盲目优化更有效。",
              @"url": @"https://developer.apple.com/xcode/"},
            @{@"id": @"frameworks", @"icon": @"puzzlepiece.fill", @"title": @"常用框架",
              @"detail": @"AFNetworking、SDWebImage 等",
              @"summary": @"理解框架解决的问题，再决定是否引入，避免依赖膨胀。",
              @"url": @"https://github.com/topics/ios"},
            @{@"id": @"opensource", @"icon": @"square.and.arrow.down.fill", @"title": @"开源项目",
              @"detail": @"GitHub 优质源码推荐",
              @"summary": @"阅读优秀开源项目是提升架构感知的捷径。",
              @"url": @"https://github.com/trending/objective-c?since=weekly"},
        ],
        @[
            @{@"id": @"community", @"icon": @"person.2.fill", @"title": @"学习社区",
              @"detail": @"Stack Overflow、掘金、简书",
              @"summary": @"遇到问题时先搜索，再提问；提问时附上最小复现。",
              @"url": @"https://stackoverflow.com/questions/tagged/ios"},
            @{@"id": @"interview", @"icon": @"graduationcap.fill", @"title": @"面试题库",
              @"detail": @"iOS 常见面试题汇总",
              @"summary": @"围绕运行时、内存、多线程、渲染与架构准备结构化答案。",
              @"url": @"https://developer.apple.com/documentation/uikit"},
        ],
    ];
}

- (NSArray<NSDictionary *> *)quizForLesson:(NSDictionary *)lesson {
    NSArray *own = lesson[@"quiz"];
    if ([own isKindOfClass:NSArray.class] && own.count > 0) {
        return own;
    }
    NSString *category = lesson[@"category"] ?: @"syntax";
    NSDictionary *bank = @{
        @"syntax": @[
            @{@"q": @"Objective-C 中实例方法的前缀符号是？", @"options": @[@"+", @"-", @"*", @"@"], @"answer": @1},
            @{@"q": @"delegate 属性通常使用哪种修饰？", @"options": @[@"strong", @"copy", @"weak", @"assign 必选 strong"], @"answer": @2},
            @{@"q": @"下列哪项最容易造成循环引用？", @"options": @[@"weak self", @"block 强持有 self 且 self 持有 block", @"NSInteger 局部变量", @"UIColor 字面量"], @"answer": @1},
        ],
        @"uikit": @[
            @{@"q": @"使用 AutoLayout 前通常需要设置？", @"options": @[@"clipsToBounds = YES", @"translatesAutoresizingMaskIntoConstraints = NO", @"opaque = NO", @"tag = 0"], @"answer": @1},
            @{@"q": @"UITableView 提升性能的关键机制是？", @"options": @[@"每次新建 Cell", @"Cell 复用", @"强制主线程同步网络", @"关闭预估高度"], @"answer": @1},
            @{@"q": @"Push 详情时想隐藏 TabBar，应设置？", @"options": @[@"modalPresentationStyle", @"hidesBottomBarWhenPushed", @"edgesForExtendedLayout", @"definesPresentationContext"], @"answer": @1},
        ],
        @"network": @[
            @{@"q": @"系统推荐的网络 API 是？", @"options": @[@"NSURLConnection", @"NSURLSession", @"CFSocket 直接用", @"UIWebView"], @"answer": @1},
            @{@"q": @"解析完 JSON 后更新 UI 应在？", @"options": @[@"任意线程", @"主线程", @"后台串行队列必选", @"信号量线程"], @"answer": @1},
            @{@"q": @"ATS 默认要求？", @"options": @[@"HTTP", @"FTP", @"HTTPS", @"自定义协议"], @"answer": @2},
        ],
        @"storage": @[
            @{@"q": @"Token 更适合存放在？", @"options": @[@"UserDefaults", @"Keychain", @"Info.plist", @"截图相册"], @"answer": @1},
            @{@"q": @"Core Data 跨线程传递 ManagedObject？", @"options": @[@"推荐直接传", @"不推荐，应传 objectID", @"必须 copy", @"只能用全局变量"], @"answer": @1},
            @{@"q": @"简单键值配置常用？", @"options": @[@"Core Animation", @"NSUserDefaults", @"Metal", @"ReplayKit"], @"answer": @1},
        ],
        @"concurrency": @[
            @{@"q": @"在主队列对主队列 sync 会？", @"options": @[@"更快", @"可能死锁", @"自动切后台", @"被编译器禁止"], @"answer": @1},
            @{@"q": @"耗时任务完成后更新 UI 应用？", @"options": @[@"dispatch_get_main_queue", @"全局队列 sync 自己", @"NSThread detach 再 detach", @"不用回调"], @"answer": @0},
            @{@"q": @"GCD 中更适合保序的是？", @"options": @[@"并发队列", @"串行队列", @"主线程 sleep", @"NSTimer"], @"answer": @1},
        ],
        @"security": @[
            @{@"q": @"上架前常用内测渠道是？", @"options": @[@"TestFlight", @"AirDrop 任意装", @"短信安装包", @"Safari 直接 ipa"], @"answer": @0},
            @{@"q": @"相机权限说明应写在？", @"options": @[@"源代码注释", @"Info.plist Usage Description", @"Assets", @"Storyboard 标题"], @"answer": @1},
            @{@"q": @"密码类数据不应放在？", @"options": @[@"Keychain", @"UserDefaults", @"安全芯片相关 API", @"系统钥匙串封装"], @"answer": @1},
        ],
    };
    return bank[category] ?: bank[@"syntax"];
}

#pragma mark - Persistence

- (void)loadPersistedState {
    NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
    NSArray *completed = [ud arrayForKey:kCompletedKey] ?: @[];
    NSArray *bookmarks = [ud arrayForKey:kBookmarksKey] ?: @[];
    self.completedIds = [NSMutableSet setWithArray:completed];
    self.bookmarkIds = [NSMutableSet setWithArray:bookmarks];
    if (![ud objectForKey:kDailyGoalKey]) {
        [ud setInteger:30 forKey:kDailyGoalKey];
    }
    if (![ud objectForKey:kReminderKey]) {
        [ud setBool:YES forKey:kReminderKey];
    }
    if (![ud stringForKey:kUserNameKey].length) {
        [ud setObject:@"学习者" forKey:kUserNameKey];
    }
    if ([ud integerForKey:kStreakKey] <= 0) {
        [ud setInteger:1 forKey:kStreakKey];
    }
}

- (void)persistSets {
    NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
    [ud setObject:self.completedIds.allObjects forKey:kCompletedKey];
    [ud setObject:self.bookmarkIds.allObjects forKey:kBookmarksKey];
    [ud synchronize];
}

- (NSString *)todayString {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    return [fmt stringFromDate:[NSDate date]];
}

- (void)refreshTodayIfNeeded {
    NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
    NSString *today = [self todayString];
    NSString *saved = [ud stringForKey:kTodayDateKey];
    if (![saved isEqualToString:today]) {
        [ud setObject:today forKey:kTodayDateKey];
        [ud setInteger:0 forKey:kTodayMinutesKey];
    }
}

- (void)notifyChange {
    [[NSNotificationCenter defaultCenter] postNotificationName:StudyDataDidChangeNotification object:self];
}

#pragma mark - Progress

- (BOOL)isLessonCompleted:(NSString *)lessonId {
    return [self.completedIds containsObject:lessonId];
}

- (void)markLessonCompleted:(NSString *)lessonId {
    if (!lessonId.length) return;
    BOOL added = ![self.completedIds containsObject:lessonId];
    [self.completedIds addObject:lessonId];
    [NSUserDefaults.standardUserDefaults setObject:lessonId forKey:kLastLessonKey];
    NSDictionary *lesson = [self lessonWithId:lessonId];
    if (added && lesson[@"minutes"]) {
        [self addStudyMinutes:[lesson[@"minutes"] integerValue]];
    } else {
        [self persistSets];
        [self notifyChange];
    }
}

- (void)unmarkLessonCompleted:(NSString *)lessonId {
    if (!lessonId.length) return;
    if (![self.completedIds containsObject:lessonId]) return;
    NSDictionary *lesson = [self lessonWithId:lessonId];
    NSInteger mins = [lesson[@"minutes"] integerValue];
    [self.completedIds removeObject:lessonId];
    if (mins > 0) {
        NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
        [self refreshTodayIfNeeded];
        NSInteger total = MAX(0, [ud integerForKey:kTotalMinutesKey] - mins);
        NSInteger today = MAX(0, [ud integerForKey:kTodayMinutesKey] - mins);
        [ud setInteger:total forKey:kTotalMinutesKey];
        [ud setInteger:today forKey:kTodayMinutesKey];
    }
    [self persistSets];
    [self notifyChange];
}

- (NSInteger)completedCount {
    return self.completedIds.count;
}

- (NSInteger)totalLessonCount {
    return self.lessons.count;
}

- (float)overallProgress {
    if (self.lessons.count == 0) return 0;
    return (float)self.completedIds.count / (float)self.lessons.count;
}

- (NSInteger)streakDays {
    return MAX(1, [NSUserDefaults.standardUserDefaults integerForKey:kStreakKey]);
}

- (NSInteger)totalStudyMinutes {
    return [NSUserDefaults.standardUserDefaults integerForKey:kTotalMinutesKey];
}

- (NSInteger)todayStudyMinutes {
    [self refreshTodayIfNeeded];
    return [NSUserDefaults.standardUserDefaults integerForKey:kTodayMinutesKey];
}

- (void)addStudyMinutes:(NSInteger)minutes {
    if (minutes <= 0) {
        [self persistSets];
        [self notifyChange];
        return;
    }
    [self refreshTodayIfNeeded];
    NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
    [ud setInteger:[ud integerForKey:kTotalMinutesKey] + minutes forKey:kTotalMinutesKey];
    [ud setInteger:[ud integerForKey:kTodayMinutesKey] + minutes forKey:kTodayMinutesKey];
    
    NSString *today = [self todayString];
    NSString *last = [ud stringForKey:kLastStudyDateKey];
    if (![last isEqualToString:today]) {
        if (last.length) {
            NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
            fmt.dateFormat = @"yyyy-MM-dd";
            NSDate *lastDate = [fmt dateFromString:last];
            NSDate *todayDate = [fmt dateFromString:today];
            NSInteger diff = (NSInteger)([todayDate timeIntervalSinceDate:lastDate] / 86400.0);
            if (diff == 1) {
                [ud setInteger:[ud integerForKey:kStreakKey] + 1 forKey:kStreakKey];
            } else if (diff > 1) {
                [ud setInteger:1 forKey:kStreakKey];
            }
        } else {
            [ud setInteger:MAX(1, [ud integerForKey:kStreakKey]) forKey:kStreakKey];
        }
        [ud setObject:today forKey:kLastStudyDateKey];
    }
    
    [self persistSets];
    [self notifyChange];
}

- (NSString *)lastLessonId {
    return [NSUserDefaults.standardUserDefaults stringForKey:kLastLessonKey];
}

- (void)setLastLessonId:(NSString *)lessonId {
    if (!lessonId.length) return;
    [NSUserDefaults.standardUserDefaults setObject:lessonId forKey:kLastLessonKey];
    [self persistSets];
    [self notifyChange];
}

- (NSDictionary *)nextLessonToContinue {
    NSString *lastId = [self lastLessonId];
    if (lastId) {
        NSDictionary *last = [self lessonWithId:lastId];
        if (last && ![self isLessonCompleted:lastId]) return last;
    }
    for (NSDictionary *lesson in self.lessons) {
        if (![self isLessonCompleted:lesson[@"id"]]) return lesson;
    }
    return nil;
}

#pragma mark - Bookmarks

- (BOOL)isBookmarked:(NSString *)lessonId {
    return [self.bookmarkIds containsObject:lessonId];
}

- (void)toggleBookmark:(NSString *)lessonId {
    if (!lessonId.length) return;
    if ([self.bookmarkIds containsObject:lessonId]) {
        [self.bookmarkIds removeObject:lessonId];
    } else {
        [self.bookmarkIds addObject:lessonId];
    }
    [self persistSets];
    [self notifyChange];
}

- (NSArray<NSDictionary *> *)bookmarkedLessons {
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *lid in self.bookmarkIds) {
        NSDictionary *lesson = [self lessonWithId:lid];
        if (lesson) [result addObject:lesson];
    }
    return result;
}

#pragma mark - Profile

- (NSString *)userName {
    return [NSUserDefaults.standardUserDefaults stringForKey:kUserNameKey] ?: @"学习者";
}

- (void)setUserName:(NSString *)name {
    NSString *value = name.length ? name : @"学习者";
    [NSUserDefaults.standardUserDefaults setObject:value forKey:kUserNameKey];
    [self notifyChange];
}

- (NSInteger)dailyGoalMinutes {
    return MAX(10, [NSUserDefaults.standardUserDefaults integerForKey:kDailyGoalKey]);
}

- (void)setDailyGoalMinutes:(NSInteger)minutes {
    [NSUserDefaults.standardUserDefaults setInteger:MAX(10, minutes) forKey:kDailyGoalKey];
    [self notifyChange];
}

- (BOOL)reminderEnabled {
    return [NSUserDefaults.standardUserDefaults boolForKey:kReminderKey];
}

- (void)setReminderEnabled:(BOOL)enabled {
    [NSUserDefaults.standardUserDefaults setBool:enabled forKey:kReminderKey];
    [self notifyChange];
}

- (void)resetAllProgress {
    [self.completedIds removeAllObjects];
    [self.bookmarkIds removeAllObjects];
    NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
    [ud removeObjectForKey:kLastLessonKey];
    [ud setInteger:0 forKey:kTotalMinutesKey];
    [ud setInteger:0 forKey:kTodayMinutesKey];
    [ud setInteger:1 forKey:kStreakKey];
    [ud removeObjectForKey:kLastStudyDateKey];
    [self persistSets];
    [self notifyChange];
}

@end
