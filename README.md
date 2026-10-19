# Scrumdinger

每日站会（Daily Scrum）管理 App —— 用来控制每位参会者的发言时长，让站会保持简短、聚焦。

基于 Apple 官方教程 [App Dev Tutorials: Getting Started with Scrumdinger](https://developer.apple.com/tutorials/app-dev-training) 实现，覆盖 SwiftUI 视图、导航、状态管理、JSON 持久化、绘图、AVFoundation 音频、单元测试与本地化，并额外加入一个网络数据示例。

## 功能

| 模块 | 说明 |
|---|---|
| 站会列表 | 卡片式列表展示所有站会，颜色随主题变化；空列表有占位提示 |
| 新建 / 编辑 | 模态表单编辑标题、参会者、时长（Stepper 5–30 分钟）与配色主题 |
| 详情页 | 展示会议信息、参会者名单、历史记录，入口为「开始会议」与「编辑」 |
| 会议计时 | 顶部进度条 + 剩余时间 + 当前发言人；用满时间播放「叮」声并自动切人，点「下一位」只换人、计时连续 |
| 环形进度环 | 每位参会者一段圆弧，当前发言人按已用时间部分填充，走满自动结束会议 |
| 历史记录 | 会议结束自动生成记录，可查看日期、人数、时长，并回放录音 |
| 录音 | 会议中可随时开始 / 停止录音，文件保存在应用沙盒并在历史记录中回放 |
| 网络数据 | 编辑页可一键从公开接口拉取参会者名单（失败有提示） |
| 本地化 | 中英双语，String Catalog 管理；麦克风权限说明同步本地化 |

## 环境要求

- macOS + Xcode 15.1 及以上
- iOS 17.2 及以上（模拟器或真机）
- 无需任何第三方依赖，不依赖 CocoaPods / Swift Package

工程由 `Scrumdinger.xcodeproj` 管理，共享 Scheme 名称 `Scrumdinger`。

## 运行

```bash
# 命令行编译
xcodebuild -project Scrumdinger.xcodeproj \
           -scheme Scrumdinger \
           -destination 'platform=iOS Simulator,name=iPhone 15' \
           build

# 运行全部测试（单元 + UI）
xcodebuild -project Scrumdinger.xcodeproj \
           -scheme Scrumdinger \
           -destination 'platform=iOS Simulator,name=iPhone 15' \
           test
```

也可以直接双击 `Scrumdinger.xcodeproj`，选择 iPhone 15 模拟器后 ⌘R。

## 目录结构

```
Scrumdinger/
├── ScrumdingerApp.swift          # @main 入口
├── Models/
│   ├── DailyScrum.swift          # 站会模型（含示例数据）
│   ├── Theme.swift               # 主题与可 Codable 的颜色值
│   ├── History.swift             # 历史记录（含录音文件名）
│   ├── ScrumTimer.swift          # 计时核心，tick() 可单测
│   ├── ScrumStore.swift          # JSON 读写 + 错误兜底
│   ├── ErrorWrapper.swift        # Identifiable 错误包装
│   ├── AudioRecorder.swift       # AVAudioRecorder 录音
│   ├── DingPlayer.swift          # 提示音播放
│   ├── AttendeeService.swift     # URLSession 网络示例
│   ├── RecordingStorage.swift    # 录音文件路径
│   └── Int+ClockFormat.swift     # 秒数 → m:ss
├── Views/
│   ├── ScrumsView / CardView / DetailView / DetailEditView
│   ├── NewScrumSheet / ThemePicker / ThemeView
│   ├── MeetingView / MeetingHeaderView / MeetingFooterView / MeetingTimerView
│   ├── SpeakerArc.swift          # 环形进度环分段 Shape
│   ├── HistoryView / ErrorView
└── Resources/
    ├── Assets.xcassets
    ├── Localizable.xcstrings     # 中英双语
    ├── InfoPlist.xcstrings       # 麦克风权限说明本地化
    └── ding.wav                  # 自制提示音
ScrumdingerTests/                 # 20 个 XCTest 单元测试
ScrumdingerUITests/               # 4 个 UI 测试（含截图用例）
screenshots/                      # 模拟器运行截图
```

## 本地化

界面文案通过 `Localizable.xcstrings` 管理，默认跟随系统语言；当前提供 English 与简体中文。主题名称（Indigo、Teal 等）保持英文原名，视为设计名词。

想强制以某种语言启动（调试用）：

```bash
xcrun simctl launch booted com.student.scrumdinger -AppleLanguages "(zh-Hans)"
```

## 数据存放

- 站会数据：`Application Support/Scrumdinger/scrums.json`（原子写入）
- 录音文件：`Application Support/Scrumdinger/Recordings/*.m4a`

首次启动会写入三条示例站会；读取失败时回退到示例数据并弹出错误提示。

## 已知限制

- 只在 iPhone 上验证过，未做 iPad 与 macOS 适配。
- 模拟器录音依赖 Mac 麦克风，音质与真机有差异。
- 会议录音只保留本次会议最近一次开始的文件，暂不支持多段拼接。
- 主题名称未翻译；App 图标仍为占位资源。

## 截图

| | |
|---|---|
| ![站会列表](screenshots/01-scrums-list.png) | ![详情页](screenshots/02-detail.png) |
| ![编辑页](screenshots/03-edit.png) | ![会议计时](screenshots/05-meeting-next-speaker.png) |
| ![历史记录](screenshots/06-detail-history.png) | ![历史详情](screenshots/07-history.png) |
| ![中文界面](screenshots/08-scrums-list-zh.png) | ![深色模式](screenshots/11-meeting-dark.png) |

## 提交记录

| 提交 | 内容 |
|---|---|
| `feat(S1)` | 声明式视图搭建计时器界面骨架 |
| `feat(S2)` | 列表、详情、编辑、新建的导航与模态 |
| `feat(S3-S5)` | 计时状态、JSON 持久化、环形进度环与录音 |
| `test(S6)` | 单元测试与 UI 走查截图用例 |
| `feat(S7)` | 中英双语、网络参会者、设计打磨 |
| `docs(S8)` | README、实训报告与截图 |

完整历史见 `git log --oneline`。
