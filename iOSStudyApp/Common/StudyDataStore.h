//
//  StudyDataStore.h
//  iOSStudyApp
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSNotificationName const StudyDataDidChangeNotification;

@interface StudyDataStore : NSObject

+ (instancetype)shared;

#pragma mark - Catalog
- (NSArray<NSDictionary *> *)allLessons;
- (NSArray<NSDictionary *> *)dailyRecommend;
- (NSArray<NSDictionary *> *)categories;
- (NSArray<NSDictionary *> *)hotCourses;
- (NSArray<NSDictionary *> *)lessonsForCategory:(NSString *)categoryId;
- (nullable NSDictionary *)lessonWithId:(NSString *)lessonId;
- (NSArray<NSArray<NSDictionary *> *> *)resourceSections;
- (NSArray<NSDictionary *> *)quizForLesson:(NSDictionary *)lesson;

#pragma mark - Progress
- (BOOL)isLessonCompleted:(NSString *)lessonId;
- (void)markLessonCompleted:(NSString *)lessonId;
- (void)unmarkLessonCompleted:(NSString *)lessonId;
- (NSInteger)completedCount;
- (NSInteger)totalLessonCount;
- (float)overallProgress;
- (NSInteger)streakDays;
- (NSInteger)totalStudySeconds;
- (NSInteger)todayStudySeconds;
- (NSInteger)totalStudyMinutes;
- (NSInteger)todayStudyMinutes;
/// Record real elapsed study time (reading / practice). Ignores tiny noise under 2s.
- (void)recordStudyDuration:(NSTimeInterval)seconds forLessonId:(nullable NSString *)lessonId;
- (void)addStudyMinutes:(NSInteger)minutes;
- (NSString *)todayStudyDurationText;
- (NSString *)totalStudyDurationText;
- (nullable NSString *)lastLessonId;
- (void)setLastLessonId:(NSString *)lessonId;
- (nullable NSDictionary *)nextLessonToContinue;

#pragma mark - Bookmarks
- (BOOL)isBookmarked:(NSString *)lessonId;
- (void)toggleBookmark:(NSString *)lessonId;
- (NSArray<NSDictionary *> *)bookmarkedLessons;

#pragma mark - Profile / Settings
- (NSString *)userName;
- (void)setUserName:(NSString *)name;
- (NSInteger)dailyGoalMinutes;
- (void)setDailyGoalMinutes:(NSInteger)minutes;
- (BOOL)reminderEnabled;
- (void)setReminderEnabled:(BOOL)enabled;
- (void)resetAllProgress;

@end

NS_ASSUME_NONNULL_END
