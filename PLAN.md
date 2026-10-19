# Scrumdinger 实训项目方案

> 依据：`doc/实训单3.docx`、`doc/Scrumdinger项目实训单 (1).docx`
> 参考：[Apple App Dev Tutorials](https://developer.apple.com/tutorials/app-dev-training)、[lucaselvaggio/Scrumdinger](https://github.com/lucaselvaggio/Scrumdinger)
> 状态：方向已确认（2026-10-19），待开工

## 1. 范围决策（已确认）

| 决策项 | 结论 |
|---|---|
| 功能范围 | Scrumdinger 主线全量 + XCTest 单元测试 + 网络数据示例；**不做** UIKit Today 式模块与 macOS 适配 |
| 持久化 | JSON 文件（`ScrumStore` + `Codable`），错误统一走 `ErrorWrapper` / `ErrorView` |
| 界面语言 | 中英双语，Xcode 15 String Catalog（`Localizable.xcstrings`），默认跟随系统 |
| 交付物 | 源码 + Git 分阶段提交 + README + 模拟器截图 + 实训报告（Markdown） |

不做的依据：详细版实训单 4.7–4.8（UIKit、网络、macOS）与评分表（第七部分，满分 100）不一致，评分表只考核 Scrumdinger 核心功能、声明式实现、状态管理、绘图音频、持久化、测试、设计、报告。网络数据作为低成本的加分演示保留。

## 2. 产品定位

Scrumdinger 帮助团队管理每日站会：为每位参会者分配发言时长，用进度条与环形进度环可视化剩余时间，用满一位的时间就播放「叮」声并在环上补一段，环填满即会议结束，会议结束自动生成历史记录并持久化。

核心用户流程：

```
ScrumsView（列表）
 ├─ 点行 → DetailView（名称 / 参会者 / 时长 / 主题色 / 历史记录）
 │    ├─ 编辑按钮 → DetailEditView（含 ThemePicker）→ 保存回写
 │    ├─ 历史记录 → HistoryView
 │    └─ 开始会议 → MeetingView（计时 + 环形进度 + 提示音 + 录音）
 └─ ＋按钮 → NewScrumSheet（模态）→ 创建后写入列表
```

## 3. 技术栈与约束

- Xcode 15.1 / iOS 17.2 SDK（**仅此 SDK**，不用 iOS 18+ API），Swift 5.9
- SwiftUI 为主，必要时桥接 UIKit（`UIViewControllerRepresentable` 仅用于录音状态展示等场景）
- 无第三方依赖；持久化 JSON；动画用 SwiftUI 内建
- 目标设备：iPhone（`TARGETED_DEVICE_FAMILY` 收窄为 1，避免 iPad 布局返工）
- Bundle ID：`com.student.scrumdinger`（当前 `-23.mm` 非法前缀需改）
- 工程名/目标名：`mm` 保留为工程容器，`PRODUCT_NAME` 改为 `Scrumdinger`、显示名本地化为 Scrumdinger

## 4. 架构与文件结构

```
Scrumdinger/
├── ScrumdingerApp.swift        // @main，注入 ScrumStore
├── Models/
│   ├── DailyScrum.swift        // 站会定义：id/title/attendees/lengthInMinutes/theme/history
│   ├── Theme.swift             // 主题：name/mainColor/accentColor
│   ├── History.swift           // 历史：date/attendees/lengthInMinutes/transcript
│   ├── ScrumTimer.swift        // 计时核心：Timer publisher → secondsElapsed/activeSpeaker
│   ├── ScrumStore.swift        // JSON 读写 + 错误
│   ├── ErrorWrapper.swift      // Identifiable 错误包装
│   └── AVPlayer+Ding.swift     // 提示音播放
├── Views/
│   ├── ScrumsView.swift        // 主页列表 + 新建入口
│   ├── CardView.swift          // 列表卡片
│   ├── DetailView.swift        // 详情 + 开始会议
│   ├── DetailEditView.swift    // 编辑（主题 Picker）
│   ├── NewScrumSheet.swift     // 模态新建
│   ├── ThemePicker.swift / ThemeView.swift
│   ├── MeetingView.swift       // 会议主界面
│   ├── MeetingHeaderView.swift / MeetingFooterView.swift / MeetingTimerView.swift
│   ├── SpeakerArc.swift        // 环形进度环分段
│   ├── HistoryView.swift
│   ├── ErrorView.swift
│   └── TrailingIconLabelStyle.swift
├── Resources/
│   ├── Assets.xcassets
│   ├── Localizable.xcstrings   // 中英双语
│   └── ding.wav（若无可改用系统音效）
└── Tests/ (mmTests)
    ├── ScrumTimerTests.swift
    ├── ModelTests.swift
    └── ScrumStoreTests.swift
```

## 5. 数据模型

| 模型 | 字段 | 说明 |
|---|---|---|
| `DailyScrum` | `id: UUID`, `title`, `attendees: [String]`, `lengthInMinutes: Int`, `theme: Theme`, `history: [History]` | `Codable`、`Identifiable` |
| `Theme` | `name`, `mainColor`, `accentColor` | 预置主题（蓝/绿/黄/橙…），色值用 `Color` 的 Codable 封装 |
| `History` | `date`, `attendees`, `lengthInMinutes`, `transcript: String` | 会议结束时追加 |
| `ScrumTimer` | `lengthInMinutes`, `attendees`, `secondsElapsed`, `secondsRemaining`, `activeSpeaker`, `isActive` | 由 `Timer.publish` 驱动，用满 1 位 → 播放叮声 + 追加弧段 + 切下一位 |

## 6. 关键实现要点

- **环形进度**：`SpeakerArc` 每段圆心角 = `360 / attendees.count`，已用完的参会者画满弧，当前者按 `elapsed / 单人时长` 画部分弧，用 `stroke(style:)` + `rotationEffect` 对齐。
- **计时**：`ScrumTimer` 不依赖视图刷新，`secondsElapsed` 变化驱动 `MeetingHeaderView` 与环重绘；切人时调用 `playDing()`。
- **提示音**：`AVAudioPlayer` 播 `ding.wav`；无音频文件时降级为 `AudioServicesPlaySystemSound`。
- **录音**：`AVAudioRecorder`，`AVAudioSession` 用 `.playAndRecord`，`Info.plist` 补 `NSMicrophoneUsageDescription`（中英双语），录音状态在 `MeetingView` 顶部指示灯显示；模拟器录音质量差属已知限制，报告里如实写。
- **持久化**：写入 `Application Support/Scrums.json`，原子写（先写临时文件再替换），读写失败全部映射为 `ErrorWrapper` 并弹 `ErrorView`。
- **网络示例**：详情页「从模板导入」按钮，`URLSession + async/await` 拉取远程 JSON（附录配置 URL），失败自动回退到内置示例，并在 UI 上标注数据来源。

## 7. 阶段计划（对齐实训单第三部分）

| 阶段 | 内容 | 验收标准 | 对应评分项 |
|---|---|---|---|
| S1 | 视图骨架：Meeting 系列 + 静态假数据 | 模拟器能跑出计时界面，纯声明式组合 | 声明式实现 15 |
| S2 | 导航与模态：列表 → 详情 → 编辑 → 新建 | 全流程可点通，编辑保存生效 | 功能 25 |
| S3 | 模型与状态：DailyScrum/Theme/History/ScrumTimer | 数据变化驱动视图刷新，无手动刷新代码 | 状态 15 |
| S4 | 持久化与错误处理 | 杀进程重启数据仍在；异常有提示 | 持久化 10 |
| S5 | 环形进度环 + 叮声 + 录音 | 用满时间自动加段，环满结束，录音可播放 | 绘图音频 15 |
| S6 | XCTest：计时、模型编解码、存储 | `xcodebuild test` 全绿 | 测试 10 |
| S7 | 设计打磨 + 网络示例 + 中英双语 | 深色模式/Dynamic Type/VoiceOver 正常，中英切换完整 | 设计 5 |
| S8 | 报告、截图、README、整合 | 7 项交付物齐全 | 报告 5 |

每阶段结束一次 Git 提交，提交信息用 `feat(S1): ...` 形式，构成「修改记录」交付物。

## 8. 交付物清单

| 序号 | 交付物 | 位置 |
|---|---|---|
| 1 | 工程源码 | 仓库根目录 |
| 2 | 修改记录 | `git log`（分阶段提交） |
| 3 | 数据模型与状态管理说明 | `REPORT.md` 第 3 章 |
| 4 | 环形进度环说明 | `REPORT.md` 第 4 章 |
| 5 | 持久化与错误处理说明 | `REPORT.md` 第 4 章 |
| 6 | 测试代码与结果 | `mmTests/` + `screenshots/test-result.png` |
| 7 | 录音与提示音说明 | `REPORT.md` 第 4 章 |
| 8 | 实训报告 | `REPORT.md`（按实训单第六部分模板） |

## 9. 风险与待办

- 工程文件（`project.pbxproj`）新增 Swift 文件需手工登记，或改用脚本批量注入；Xcode 15.1 不支持文件系统同步组。
- 录音在模拟器上受限，需在报告与演示话术中说明。
- `ding.wav` 版权：优先用自制合成音，避免引入第三方素材。
- 待办：`git init`、`.gitignore`、修正 Bundle ID、`knownRegions` 增加 `zh-Hans`。

## 10. 实施记录（2026-10-19）

### 已完成

| 阶段 | 结果 |
|---|---|
| S1 | 工程重建为 `Scrumdinger.xcodeproj`（目标名、Bundle ID 修正），Meeting 界面骨架可运行 |
| S2 | 列表 / 详情 / 编辑 / 新建全流程打通，主题切换可用 |
| S3–S5 | `ScrumTimer` 计时与叮声、JSON 持久化与错误兜底、`SpeakerArc` 环形进度环、`AudioRecorder` 录音与历史回放 |
| S6 | 19 个 XCTest 单元测试 + 4 个 UI 测试（含截图用例），全部通过 |
| S7 | 中英双语 String Catalog、`AttendeeService` 网络参会者、深色模式与设计打磨 |
| S8 | README、实训报告、运行截图、测试日志 |

### 与计划的偏差

1. **提交粒度**：S3、S4、S5 实现在同一轮完成，合并为一次提交 `feat(S3-S5)`，未做到每阶段独立提交。
2. **网络示例形式**：改为编辑页「从网络获取参会者」（JSONPlaceholder users 接口），比「详情页导入模板」更稳定、语义更自然。
3. **测试产出截图**：截图由 `ScrumdingerUITests` 自动产出到 runner 沙盒，再拷回 `screenshots/`，保证与代码版本一致。
4. **未做项**：UIKit 模块、iPad / macOS 适配（按已确认范围排除）。

### 验收对照

评分表八个维度均有对应实现与说明；测试命令、截图与报告分别见 `test-results.txt`、`screenshots/`、`REPORT.md`。

## 11. 第二阶段扩展（同日）

按新需求把 App 扩成双 Tab 结构，并降到 iOS 16：

- `RootTabView`：每日站会 / 我的；
- 每日站会改为浅色卡片（圆角 14、柔和阴影），点击卡片直接开始计时，长按进详情；
- 「我的」：个人信息、4 个快捷入口、设置列表；
- 新增我的任务、日程会议、阻塞事项、站会纪要四个 MVVM 页面；
- 会议页「下一位」改为弹出 `SpeakerPickerView`，可指定任意未发言的人，计时不中断；
- 部署目标 17.2 → 16.0，替换 `ContentUnavailableView`、`AVAudioApplication`、双参数 `onChange`、`.topBarTrailing` 等 iOS 17 API；
- 单测 22 个、UI 测试 4 个，全部通过。
