# 好友列表与学习动态 Plan

> Plan gate 以 `asd/state/plan-gates/friend-list.json` 为准（通过 `asd_plan_approve`）。  
> 分支：`cursor/lessons-json-deep-content`

## 目标

在学习 App 中增加「好友」能力：可添加好友，进入好友详情查看其学习记录与学习时长。  
数据策略为**本地模拟（方案 A）**：无真实账号/后端，好友与学习动态均存本机。

## 已确认决策

| 项 | 选择 |
|----|------|
| 数据策略 | A. 本地模拟好友 + 种子学习动态 |
| 入口 | 新增 Tab「好友」（放在「资源」与「设置」之间） |
| 添加方式 | 从本地可添加候选人中按昵称搜索并添加；已添加不可重复 |
| 好友动态 | 详情页展示总学习时长、今日时长、最近学习记录列表（课程名 + 完成/学习时间） |
| 持久化 | `NSUserDefaults`（与现有 `StudyDataStore` 风格一致） |
| 范围外 | 真实社交、推送、云端同步、好友申请双向确认、聊天 |

## 任务拆解

| ID | 任务 | 产出 | 验证 |
|----|------|------|------|
| T-1 | 新增 `FriendStore`：候选人目录、好友列表 CRUD、按好友 ID 取模拟学习时长与最近记录；持久化好友 ID 列表 | `iOSStudyApp/Common/FriendStore.h/.m` | 添加/重复添加/删除（若提供）行为正确；杀进程后好友仍在 |
| T-2 | 好友列表页：展示头像占位、昵称、总时长摘要；空态；导航栏「添加」 | `iOSStudyApp/Modules/Friends/FriendsViewController.h/.m` | 列表刷新；空态可见 |
| T-3 | 添加好友页：搜索过滤候选人；点选添加；已是好友禁用或提示 | `FriendsAddViewController.h/.m` | 搜到候选人；添加成功回列表；重复添加有提示 |
| T-4 | 好友详情页：总时长、今日时长、学习记录列表 | `FriendDetailViewController.h/.m` | 字段齐全；记录非空（种子数据） |
| T-5 | 接入 TabBar：注册好友 Tab 与导航栈；沿用 `MYTheme` / `MYNavigationController` | `MYTabBarController.m` + Xcode 工程引用 | App 启动可见「好友」Tab，可 push 详情 |
| T-6 | 将新 `.m` 文件加入 `iOSStudyApp.xcodeproj` | `project.pbxproj` | Xcode 编译通过 |

## 验收标准（AC）

1. **AC-1 入口**：底部存在「好友」Tab，可进入好友列表。
2. **AC-2 添加好友**：可通过搜索从本地候选人添加好友；重复添加有明确提示且列表不重复。
3. **AC-3 列表摘要**：好友列表每项至少展示昵称与学习总时长（分钟）。
4. **AC-4 学习详情**：点进好友可看到总学习时长、今日学习时长、至少一条学习记录（课程名 + 时间相关信息）。
5. **AC-5 本地持久化**：重启 App 后已添加好友仍存在。
6. **AC-6 无后端依赖**：不新增网络请求；不改动现有课程 `lessons.json` 学习主流程（只读复用课程名可选）。

## AC → 任务映射

| AC | 任务 |
|----|------|
| AC-1 | T-5 |
| AC-2 | T-1, T-3 |
| AC-3 | T-1, T-2 |
| AC-4 | T-1, T-4 |
| AC-5 | T-1 |
| AC-6 | 全任务约束 |

## 验证策略

| 命令 / 检查 | 目的 |
|-------------|------|
| `xcodebuild -scheme iOSStudyApp -destination 'platform=iOS Simulator,name=iPhone 16' build`（或本机可用 simulator） | 编译通过 |
| 模拟器手测：添加 → 列表 → 详情 → 杀进程再开 | AC-1～AC-5 |
| `rg -n "FriendStore|FriendsViewController" iOSStudyApp` | 关键文件落点 |

## 风险与回滚

| 风险 | 处理 |
|------|------|
| Tab 过多挤压 | 固定 5 Tab；图标用 SF Symbols `person.2` |
| 工程未加入新文件导致链接失败 | T-6 专门改 pbxproj；编译验证 |
| 与旧 `ios-foundation-learning-doc` 工作项混淆 | 仅在 `friend-list` plan 范围改 Friends 相关代码 |
| Guard 被无关 untracked 文件干扰 | 实现前保持业务改动仅限 plan 路径；勿提交无关 `.DS_Store` |

## 推荐默认种子数据（实现时可微调）

- 候选人示例：小明、小红、Alex、Sara 等（含不同总时长与 2～5 条最近记录）
- 新添加好友后即可查看其固定种子动态（演示用，不随真实学习变化）
