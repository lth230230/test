# iOSStudyApp Full Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Merge the enhanced ObjC/UIKit learning assistant from `~/test/iOSStudyApp` into the Git-connected `Desktop/demo/iOSStudyApp`, then close spec gaps so progress, practice, bookmarks, resources, settings, and unified theme all work end-to-end.

**Architecture:** Keep four-tab UIKit app. Add `Common/MYTheme` + `Common/StudyDataStore` as the single source of truth (in-memory catalog + UserDefaults persistence + `StudyDataDidChangeNotification`). Replace Base/Modules screens with the enhanced versions; polish continue-learning empty state and no-quiz practice entry.

**Tech Stack:** Objective-C, UIKit, UserDefaults, SF Symbols, Xcode project (`project.pbxproj`)

**Spec:** `docs/superpowers/specs/2026-07-21-iosstudyapp-full-optimization-design.md`

## Global Constraints

- Target repo only: `/Users/litianhao/Desktop/demo/iOSStudyApp` (never edit `~/test` as the deliverable)
- Stay Objective-C + UIKit; no SwiftUI rewrite
- No login, system push notifications, iCloud, or network course fetch
- Reminder switch stores preference only (no UNUserNotificationCenter)
- Prefer hiding「开始练习」when `quizForLesson:` returns empty
- Visual tokens only via `MYTheme` (no new hard-coded theme colors in screens)
- Source of enhanced code: `/Users/litianhao/test/iOSStudyApp` (+ matching `project.pbxproj` under `/Users/litianhao/test/iOSStudyApp.xcodeproj/`)

---

## File Structure (post-merge)

```
iOSStudyApp/
  Common/
    MYTheme.h / MYTheme.m
    StudyDataStore.h / StudyDataStore.m
  Base/
    MYTabBarController.* / MYNavigationController.*
  Modules/
    Home/     HomeViewController, HomeHeaderView, HomeCell, LearnDetailViewController
    Learn/    LearnViewController, CourseListViewController
    Practice/ PracticeViewController
    Resources/ ResourcesViewController, ResourceDetailViewController
    Settings/ SettingsViewController
iOSStudyApp.xcodeproj/project.pbxproj   # must list all new .m in Compile Sources
```

**Key interfaces (StudyDataStore):**

```objc
FOUNDATION_EXPORT NSNotificationName const StudyDataDidChangeNotification;
+ (instancetype)shared;
- (NSArray<NSDictionary *> *)dailyRecommend;
- (NSArray<NSDictionary *> *)categories;
- (NSArray<NSDictionary *> *)hotCourses;
- (NSArray<NSDictionary *> *)lessonsForCategory:(NSString *)categoryId;
- (NSArray<NSDictionary *> *)quizForLesson:(NSDictionary *)lesson;
- (BOOL)isLessonCompleted:(NSString *)lessonId;
- (void)markLessonCompleted:(NSString *)lessonId;
- (void)toggleBookmark:(NSString *)lessonId;
- (nullable NSDictionary *)nextLessonToContinue;
- (void)addStudyMinutes:(NSInteger)minutes;
- (void)setUserName:(NSString *)name;
- (void)setDailyGoalMinutes:(NSInteger)minutes;
- (void)setReminderEnabled:(BOOL)enabled;
- (void)resetAllProgress;
```

**Key UI contracts:**

```objc
// HomeHeaderView.h
@property (nonatomic, copy) void (^onContinue)(void);
- (void)refresh;

// PracticeViewController.h
@property (nonatomic, strong) NSDictionary *lesson;

// LearnDetailViewController.h
@property (nonatomic, strong) NSDictionary *data;
```

---

### Task 1: Merge Common layer + Xcode project wiring

**Files:**
- Create: `iOSStudyApp/Common/MYTheme.h`, `iOSStudyApp/Common/MYTheme.m`, `iOSStudyApp/Common/StudyDataStore.h`, `iOSStudyApp/Common/StudyDataStore.m`
- Replace: `iOSStudyApp.xcodeproj/project.pbxproj` (from enhanced project that already references Common + new VCs)
- Verify: file existence + `pbxproj` contains Compile Sources entries

**Interfaces:**
- Consumes: enhanced sources under `/Users/litianhao/test/iOSStudyApp/Common/` and `/Users/litianhao/test/iOSStudyApp.xcodeproj/project.pbxproj`
- Produces: `MYTheme` + `StudyDataStore` on disk; pbxproj with `B10016`–`B10020` build files and `B40012` Common / `B40013` Practice groups

- [ ] **Step 1: Write failing verification script**

Create `scripts/verify-merge.sh`:

```bash
#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
need() {
  if [[ ! -f "$ROOT/$1" ]]; then echo "MISSING $1"; fail=1; fi
}
need "iOSStudyApp/Common/MYTheme.h"
need "iOSStudyApp/Common/MYTheme.m"
need "iOSStudyApp/Common/StudyDataStore.h"
need "iOSStudyApp/Common/StudyDataStore.m"
need "iOSStudyApp/Modules/Practice/PracticeViewController.m"
need "iOSStudyApp/Modules/Learn/CourseListViewController.m"
need "iOSStudyApp/Modules/Resources/ResourceDetailViewController.m"
grep -q "MYTheme.m in Sources" "$ROOT/iOSStudyApp.xcodeproj/project.pbxproj" || { echo "pbxproj missing MYTheme"; fail=1; }
grep -q "StudyDataStore.m in Sources" "$ROOT/iOSStudyApp.xcodeproj/project.pbxproj" || { echo "pbxproj missing StudyDataStore"; fail=1; }
grep -q "PracticeViewController.m in Sources" "$ROOT/iOSStudyApp.xcodeproj/project.pbxproj" || { echo "pbxproj missing Practice"; fail=1; }
exit $fail
```

- [ ] **Step 2: Run script — expect FAIL**

```bash
chmod +x scripts/verify-merge.sh
./scripts/verify-merge.sh
```

Expected: prints `MISSING iOSStudyApp/Common/...` and exits non-zero.

- [ ] **Step 3: Copy Common sources**

```bash
mkdir -p iOSStudyApp/Common
cp /Users/litianhao/test/iOSStudyApp/Common/MYTheme.h iOSStudyApp/Common/
cp /Users/litianhao/test/iOSStudyApp/Common/MYTheme.m iOSStudyApp/Common/
cp /Users/litianhao/test/iOSStudyApp/Common/StudyDataStore.h iOSStudyApp/Common/
cp /Users/litianhao/test/iOSStudyApp/Common/StudyDataStore.m iOSStudyApp/Common/
```

- [ ] **Step 4: Install enhanced pbxproj**

```bash
cp /Users/litianhao/test/iOSStudyApp.xcodeproj/project.pbxproj \
   iOSStudyApp.xcodeproj/project.pbxproj
```

Confirm groups exist: `Common`, `Practice`, and Sources include `CourseListViewController.m`, `ResourceDetailViewController.m`.

- [ ] **Step 5: Re-run verify (still expect FAIL until Task 2 copies modules)**

```bash
./scripts/verify-merge.sh || true
```

Expected: Common + pbxproj lines pass; Practice/CourseList/ResourceDetail files still MISSING.

- [ ] **Step 6: Commit Common + pbxproj + script**

```bash
git add scripts/verify-merge.sh iOSStudyApp/Common \
  iOSStudyApp.xcodeproj/project.pbxproj
git commit -m "$(cat <<'EOF'
feat: add StudyDataStore, MYTheme, and enhanced pbxproj wiring

Bring in the shared catalog/progress layer and project references
needed for the full learning-loop merge.
EOF
)"
```

---

### Task 2: Replace Base + Modules from enhanced tree

**Files:**
- Replace/Create under `iOSStudyApp/Base/` and `iOSStudyApp/Modules/**`
- Also sync: `SceneDelegate.m`, `Info.plist` if enhanced differs (copy from source)
- Do **not** delete `docs/`

**Interfaces:**
- Consumes: `MYTheme`, `StudyDataStore` from Task 1
- Produces: Home search/filter/continue; Learn categories + CourseList; Practice quiz UI; Resources detail; Settings real CRUD

- [ ] **Step 1: Sync source tree (exact commands)**

```bash
# Base
cp /Users/litianhao/test/iOSStudyApp/Base/MYNavigationController.h iOSStudyApp/Base/
cp /Users/litianhao/test/iOSStudyApp/Base/MYNavigationController.m iOSStudyApp/Base/
cp /Users/litianhao/test/iOSStudyApp/Base/MYTabBarController.h iOSStudyApp/Base/
cp /Users/litianhao/test/iOSStudyApp/Base/MYTabBarController.m iOSStudyApp/Base/

# Home
cp /Users/litianhao/test/iOSStudyApp/Modules/Home/*.{h,m} iOSStudyApp/Modules/Home/

# Learn + new CourseList
mkdir -p iOSStudyApp/Modules/Learn
cp /Users/litianhao/test/iOSStudyApp/Modules/Learn/*.{h,m} iOSStudyApp/Modules/Learn/

# Practice (new)
mkdir -p iOSStudyApp/Modules/Practice
cp /Users/litianhao/test/iOSStudyApp/Modules/Practice/*.{h,m} iOSStudyApp/Modules/Practice/

# Resources + detail
mkdir -p iOSStudyApp/Modules/Resources
cp /Users/litianhao/test/iOSStudyApp/Modules/Resources/*.{h,m} iOSStudyApp/Modules/Resources/

# Settings
cp /Users/litianhao/test/iOSStudyApp/Modules/Settings/*.{h,m} iOSStudyApp/Modules/Settings/

# App shell
cp /Users/litianhao/test/iOSStudyApp/SceneDelegate.m iOSStudyApp/
cp /Users/litianhao/test/iOSStudyApp/Info.plist iOSStudyApp/
```

- [ ] **Step 2: Run verify — expect PASS**

```bash
./scripts/verify-merge.sh
```

Expected: exit 0, no MISSING lines.

- [ ] **Step 3: Spot-check critical imports**

```bash
rg -n "#import \"MYTheme.h\"|#import \"StudyDataStore.h\"|#import \"PracticeViewController.h\"" \
  iOSStudyApp/Modules iOSStudyApp/Base | head -40
```

Expected: Home/Learn/Practice/Resources/Settings and Base reference theme/store as in enhanced app.

- [ ] **Step 4: Commit module merge**

```bash
git add iOSStudyApp
git commit -m "$(cat <<'EOF'
feat: merge enhanced home, learn, practice, resources, settings

Replace static alert-only screens with the full local learning loop UI.
EOF
)"
```

---

### Task 3: Close spec gaps (continue empty + no-quiz practice)

**Files:**
- Modify: `iOSStudyApp/Modules/Home/HomeViewController.m` (`continueLearning`)
- Modify: `iOSStudyApp/Modules/Home/LearnDetailViewController.m` (`configureData` / practice button visibility)
- Optional harden: `iOSStudyApp/Modules/Practice/PracticeViewController.m` if questions empty

**Interfaces:**
- Consumes: `-[StudyDataStore nextLessonToContinue]`, `-[StudyDataStore quizForLesson:]`
- Produces: alert when nothing to continue; hidden practice button when quiz empty

- [ ] **Step 1: Confirm current gap (failing behavior checklist)**

In code review of merged files, verify:
1. `continueLearning` returns silently when `next == nil` (spec wants prompt)
2. `configureData` does not hide `practiceBtn` when quiz is empty

- [ ] **Step 2: Fix continue-learning empty state**

In `HomeViewController.m`, replace `continueLearning` with:

```objc
- (void)continueLearning {
    NSDictionary *next = [[StudyDataStore shared] nextLessonToContinue];
    if (!next) {
        UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"暂无待学课程"
                                               message:@"去课程列表挑一课开始学习吧"
                                        preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"好的"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [self openLesson:next];
}
```

- [ ] **Step 3: Hide practice when no quiz**

In `LearnDetailViewController.m` `configureData`, after updating complete button, add:

```objc
NSArray *quiz = [store quizForLesson:self.data];
BOOL hasQuiz = quiz.count > 0;
self.practiceBtn.hidden = !hasQuiz;
self.practiceBtn.enabled = hasQuiz;
self.practiceBtn.alpha = hasQuiz ? 1.0 : 0.0;
```

Prefer hidden per spec. Also guard `startPractice`:

```objc
- (void)startPractice {
    if ([[StudyDataStore shared] quizForLesson:self.data].count == 0) {
        UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"暂无练习"
                                               message:@"这节课还没有测验题"
                                        preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"好的"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    PracticeViewController *practice = [[PracticeViewController alloc] init];
    practice.lesson = self.data;
    [self.navigationController pushViewController:practice animated:YES];
}
```

- [ ] **Step 4: Guard empty PracticeViewController**

After loading questions in `viewDidLoad` (before `renderQuestion`):

```objc
if (self.questions.count == 0) {
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"暂无练习"
                                           message:@"这节课还没有测验题"
                                    preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"返回"
                                              style:UIAlertActionStyleDefault
                                            handler:^(__unused UIAlertAction *action) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
    return;
}
```

- [ ] **Step 5: Commit polish**

```bash
git add iOSStudyApp/Modules/Home/HomeViewController.m \
  iOSStudyApp/Modules/Home/LearnDetailViewController.m \
  iOSStudyApp/Modules/Practice/PracticeViewController.m
git commit -m "$(cat <<'EOF'
fix: handle empty continue-learning and missing quizzes

Match the approved spec edge cases for home continue and practice entry.
EOF
)"
```

---

### Task 4: Build + acceptance verification

**Files:**
- None required unless build errors force fixes
- Test: `scripts/verify-merge.sh` + `xcodebuild`

**Interfaces:**
- Consumes: full merged app
- Produces: green build evidence + manual checklist result

- [ ] **Step 1: Resolve simulator destination**

```bash
xcodebuild -project iOSStudyApp.xcodeproj -scheme iOSStudyApp -showdestinations 2>/dev/null | head -40
```

Pick an available iOS Simulator. If none, use `generic/platform=iOS Simulator`.

- [ ] **Step 2: Build**

```bash
xcodebuild \
  -project iOSStudyApp.xcodeproj \
  -scheme iOSStudyApp \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Expected: `** BUILD SUCCEEDED **`

If compile errors, fix `project.pbxproj` or missing copies, then rebuild until success.

- [ ] **Step 3: Re-run merge verify**

```bash
./scripts/verify-merge.sh
```

Expected: exit 0.

- [ ] **Step 4: Manual acceptance checklist (Xcode Run on simulator)**

Open **only** `/Users/litianhao/Desktop/demo/iOSStudyApp/iOSStudyApp.xcodeproj` and verify:

1. Theme consistent across 4 tabs (background + primary teal, cards)
2. Home: filter + search + continue learning; complete a lesson; stats update
3. Detail: bookmark toggle; mark complete; start practice; finish quiz; minutes increase
4. Learn: category → course list → detail
5. Resources: row opens detail (not alert-only)
6. Settings: edit name + daily goal; reminder switch persists; reset clears progress
7. Kill/relaunch app: progress/bookmarks persist

- [ ] **Step 5: Final commit if build-only fixes remain**

```bash
git status
# if fixes:
git add -A
git commit -m "$(cat <<'EOF'
chore: fix build issues after learning-loop merge

Ensure the optimized iOSStudyApp compiles for the iOS Simulator.
EOF
)"
```

---

## Self-Review (plan vs spec)

| Spec requirement | Task |
|------------------|------|
| Unified MYTheme | Task 1–2 |
| StudyDataStore progress/bookmarks/settings | Task 1–2 |
| Home progress card, filter, search, continue | Task 2 + Task 3 empty continue |
| Detail complete + bookmark + practice | Task 2 + Task 3 no-quiz |
| Learn categories + CourseList + hot | Task 2 |
| Practice quiz + score + minutes | Task 2 |
| Resources detail | Task 2 |
| Settings real CRUD + reset | Task 2 |
| Edge: empty continue / no quiz / search empty / reset | Task 3 (search empty already in enhanced Home) |
| Git-connected Desktop/demo path | Global Constraints |
| No login/push/iCloud/network | Global Constraints |

No TBD placeholders remain. Method names match `StudyDataStore.h` / enhanced headers.
