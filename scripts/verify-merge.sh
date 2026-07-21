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
