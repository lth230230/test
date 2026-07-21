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
    self.lessons = @[
        @{@"id": @"oc-basics", @"title": @"Objective-C 基础语法", @"desc": @"数据类型、方法调用、属性声明",
          @"time": @"15分钟", @"minutes": @15, @"tag": @"入门", @"category": @"syntax",
          @"content": @"Objective-C 是 iOS 早期主流语言，理解它能帮你读懂大量存量代码与底层文档。\n\n一、概念理解\n\nOC 基于 C 语言，加入了面向对象消息发送机制。对象通过指针引用，消息通过 [receiver method] 调用。\n\n二、核心要点\n\n1. 熟悉 NSInteger、CGFloat、BOOL 等常用类型\n2. 掌握 @property / @synthesize 与自动生成访问器\n3. 理解实例方法 (-) 与类方法 (+)\n4. 学会阅读头文件接口定义\n\n三、代码示例\n\n@interface Person : NSObject\n@property (nonatomic, copy) NSString *name;\n- (void)sayHello;\n@end\n\n四、注意事项\n\n• 字符串优先用 copy\n• 避免在 init/dealloc 中调用可被重写的方法\n• 熟悉 nil 消息安全机制"},
        @{@"id": @"autolayout", @"title": @"AutoLayout 约束实战", @"desc": @"纯代码布局与 Masonry 使用技巧",
          @"time": @"20分钟", @"minutes": @20, @"tag": @"进阶", @"category": @"uikit",
          @"content": @"AutoLayout 让界面适配不同屏幕尺寸。\n\n一、概念理解\n\n约束描述视图之间的关系。优先使用 NSLayoutAnchor，也可用第三方 DSL。\n\n二、核心要点\n\n1. translatesAutoresizingMaskIntoConstraints = NO\n2. 明确宽高或相对关系，避免约束冲突\n3. 使用 Content Hugging / Compression Resistance\n4. 动态高度 Cell 需要正确设置约束链\n\n三、代码示例\n\nlabel.translatesAutoresizingMaskIntoConstraints = NO;\n[NSLayoutConstraint activateConstraints:@[\n  [label.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:16],\n  [label.topAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide.topAnchor constant:16]\n]];\n\n四、注意事项\n\n• 冲突时用优先级拆解\n• 避免循环依赖\n• 旋转后检查布局更新"},
        @{@"id": @"tableview", @"title": @"UITableView 复用机制", @"desc": @"Cell 重用池、高度缓存、滑动优化",
          @"time": @"25分钟", @"minutes": @25, @"tag": @"核心", @"category": @"uikit",
          @"content": @"列表性能是 iOS 面试与实战的高频主题。\n\n一、概念理解\n\nUITableView 通过复用池减少创建成本，只保留可见区域附近的 Cell。\n\n二、核心要点\n\n1. registerClass / dequeueReusableCell\n2. 在 prepareForReuse 重置状态\n3. estimatedRowHeight + 自动高度\n4. 异步加载图片并取消过期任务\n\n三、代码示例\n\n[tableView registerClass:HomeCell.class forCellReuseIdentifier:@\"HomeCell\"];\nHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@\"HomeCell\" forIndexPath:indexPath];\n\n四、注意事项\n\n• 避免在 cellForRow 做重计算\n• 图片占位与尺寸固定减少抖动\n• 主线程只做轻量 UI 更新"},
        @{@"id": @"network", @"title": @"网络请求与数据解析", @"desc": @"NSURLSession + JSON 模型转换",
          @"time": @"30分钟", @"minutes": @30, @"tag": @"进阶", @"category": @"network",
          @"content": @"移动端几乎都会和后端交互。\n\n一、概念理解\n\nNSURLSession 是系统推荐网络栈，配合 JSONSerialization 或模型库完成解析。\n\n二、核心要点\n\n1. dataTask / downloadTask 的区别\n2. HTTP 状态码与错误域处理\n3. 主线程回调更新 UI\n4. 取消任务与超时配置\n\n三、代码示例\n\nNSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *resp, NSError *error) {\n  // parse on background, update UI on main\n}];\n[task resume];\n\n四、注意事项\n\n• ATS 与 HTTPS\n• 敏感信息不写死在客户端\n• 做好弱网重试与幂等"},
        @{@"id": @"coredata", @"title": @"CoreData 数据持久化", @"desc": @"增删改查、多线程、迁移",
          @"time": @"35分钟", @"minutes": @35, @"tag": @"高阶", @"category": @"storage",
          @"content": @"Core Data 适合结构化本地数据与复杂查询。\n\n一、概念理解\n\nNSManagedObjectContext 管理对象图，配合 Persistent Store 落盘。\n\n二、核心要点\n\n1. 主上下文与后台上下文分工\n2. performBlock 保证线程安全\n3. 轻量迁移与版本管理\n4. 批量删除与故障恢复\n\n三、代码示例\n\nNSFetchRequest *request = [MyEntity fetchRequest];\nrequest.predicate = [NSPredicate predicateWithFormat:@\"done == NO\"];\nNSArray *result = [context executeFetchRequest:request error:nil];\n\n四、注意事项\n\n• 不要跨线程传递 ManagedObject\n• 大对象考虑外存\n• 保存失败要处理 merge 冲突"},
        @{@"id": @"gcd", @"title": @"多线程与 GCD", @"desc": @"队列、信号量、死锁避免",
          @"time": @"25分钟", @"minutes": @25, @"tag": @"核心", @"category": @"concurrency",
          @"content": @"并发写不好就会卡顿甚至崩溃。\n\n一、概念理解\n\nGCD 用队列调度任务。串行队列保序，并发队列提吞吐。\n\n二、核心要点\n\n1. sync / async 的区别\n2. 主队列不要 sync 自己（死锁）\n3. dispatch_group / semaphore 的适用场景\n4. barrier 保护并发写\n\n三、代码示例\n\ndispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{\n  // 耗时任务\n  dispatch_async(dispatch_get_main_queue(), ^{\n    // 更新 UI\n  });\n});\n\n四、注意事项\n\n• UI 必须在主线程\n• 合理选择 QoS\n• 避免无界并发打爆资源"},
        @{@"id": @"arc", @"title": @"内存管理与 ARC", @"desc": @"循环引用、weak/strong、自动释放池",
          @"time": @"20分钟", @"minutes": @20, @"tag": @"核心", @"category": @"syntax",
          @"content": @"ARC 降低了手动 retain/release 成本，但循环引用仍需警惕。\n\n一、概念理解\n\n强引用延长生命周期，弱引用不增加引用计数。\n\n二、核心要点\n\n1. block 捕获 self 的常见环\n2. weak-strong dance\n3. delegate 通常用 weak\n4. @autoreleasepool 批量临时对象\n\n三、代码示例\n\n__weak typeof(self) weakSelf = self;\nself.completion = ^{\n  __strong typeof(weakSelf) strongSelf = weakSelf;\n  [strongSelf refresh];\n};\n\n四、注意事项\n\n• 工具：Instruments Leaks / Debug Memory Graph\n• 及时置空定时器与观察者\n• 大图注意解码尺寸"},
        @{@"id": @"release", @"title": @"App 上架全流程", @"desc": @"证书、打包、TestFlight、审核",
          @"time": @"15分钟", @"minutes": @15, @"tag": @"实战", @"category": @"security",
          @"content": @"从开发到上架是完整交付能力的一部分。\n\n一、概念理解\n\n证书、描述文件、Bundle ID 共同决定签名身份。\n\n二、核心要点\n\n1. Development / Distribution 证书\n2. Archive + Organizer 上传\n3. TestFlight 内测\n4. 审核常见驳回点（隐私、登录、崩溃）\n\n三、代码示例\n\n// Info.plist 配置隐私用途说明\n// NSCameraUsageDescription = 用于扫描学习资料\n\n四、注意事项\n\n• 版本号与 Build 号递增\n• 准备审核账号与演示数据\n• 关注出口合规与加密声明"},
        @{@"id": @"uikit-nav", @"title": @"导航与页面流转", @"desc": @"UINavigationController 与模态呈现",
          @"time": @"18分钟", @"minutes": @18, @"tag": @"入门", @"category": @"uikit",
          @"content": @"掌握页面栈才能组织复杂 App。\n\n一、概念理解\n\nPush 进入层级，Present 弹出临时任务。\n\n二、核心要点\n\n1. hidesBottomBarWhenPushed\n2. 自定义转场\n3. 返回手势与拦截\n4. 大标题与外观统一\n\n三、注意事项\n\n• 避免过深导航栈\n• 统一返回行为\n• 注意内存中多个 VC 并存"},
        @{@"id": @"json-model", @"title": @"JSON 与模型映射", @"desc": @"字典转模型、可选字段与容错",
          @"time": @"22分钟", @"minutes": @22, @"tag": @"进阶", @"category": @"network",
          @"content": @"接口字段经常变化，容错很重要。\n\n一、核心要点\n\n1. 类型校验\n2. 默认值策略\n3. 嵌套模型\n4. 列表解析\n\n二、注意事项\n\n• 不要假设字段一定存在\n• 日志脱敏\n• 单测覆盖异常 JSON"},
        @{@"id": @"sqlite", @"title": @"SQLite 轻量存储", @"desc": @"适合缓存与简单关系数据",
          @"time": @"20分钟", @"minutes": @20, @"tag": @"进阶", @"category": @"storage",
          @"content": @"当不需要 Core Data 全套能力时，SQLite / FMDB 更轻。\n\n核心要点：事务、索引、迁移脚本、主线程禁止重查询。"},
        @{@"id": @"operation", @"title": @"NSOperation 任务编排", @"desc": @"依赖、取消与最大并发数",
          @"time": @"24分钟", @"minutes": @24, @"tag": @"高阶", @"category": @"concurrency",
          @"content": @"比纯 GCD 更适合可取消、有依赖的任务流。\n\n核心要点：isFinished/KVO、queue Priority、避免在主队列塞重任务。"},
        @{@"id": @"keystore", @"title": @"Keychain 与本地安全", @"desc": @"令牌存储、生物识别补充",
          @"time": @"16分钟", @"minutes": @16, @"tag": @"实战", @"category": @"security",
          @"content": @"密码和 Token 不要放 UserDefaults。\n\n使用 Keychain Services，并结合 Face ID / Touch ID 做二次确认。"},
        @{@"id": @"runtime", @"title": @"Runtime 与消息转发", @"desc": @"Method Swizzling 边界与风险",
          @"time": @"28分钟", @"minutes": @28, @"tag": @"高阶", @"category": @"syntax",
          @"content": @"Runtime 强大但危险。只在充分理解副作用时使用 Swizzling，并做好版本兼容。"},
        @{@"id": @"perf", @"title": @"启动与滑动性能优化", @"desc": @"Time Profiler、卡顿排查思路",
          @"time": @"30分钟", @"minutes": @30, @"tag": @"实战", @"category": @"uikit",
          @"content": @"优化要先测量。关注 main() 前耗时、首屏渲染、离屏渲染与过度绘制。"},
        @{@"id": @"ats", @"title": @"ATS 与网络安全", @"desc": @"证书锁定、明文限制例外",
          @"time": @"14分钟", @"minutes": @14, @"tag": @"核心", @"category": @"security",
          @"content": @"默认要求 HTTPS。临时例外要最小化，并尽快移除。"},
    ];
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
