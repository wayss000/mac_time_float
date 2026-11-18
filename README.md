# TimeFloat

一个原生、离线运行的 macOS 悬浮时钟。支持 macOS 13 及以上，无账号、无服务器、无第三方依赖。

## 下载使用

打开 **<https://wayss000.github.io/mac_time_float/>**，页面会自动展示最新版本、发布时间和安装包大小，按芯片选择：

- **Apple Silicon**（`TimeFloat-macOS-arm64.zip`）：M1/M2/M3/M4 等。
- **Intel**（`TimeFloat-macOS-x86_64.zip`）：Intel Mac。

下载后解压，将 `TimeFloat.app` 拖到“应用程序”，双击启动。历史版本见 [Releases](https://github.com/wayss000/mac_time_float/releases)。

产物经过临时签名，但尚未使用 Apple Developer ID 签名或公证。如果系统阻止首次打开，在确认下载来源为本仓库后，前往“系统设置 → 隐私与安全性”选择“仍要打开”。

## 操作

- 拖动时钟卡片可移动窗口，拖动四边或四角可按比例缩放。
- 点击菜单栏的时钟图标可显示/隐藏时钟、切换 12/24 小时制、置顶或退出应用。

## 本机开发（macOS）

安装 Xcode Command Line Tools（`xcode-select --install`），然后：

```sh
swift test
swift run TimeFloat
scripts/build-app.sh arm64
# Intel 版本：scripts/build-app.sh x86_64
open build/arm64/TimeFloat.app
```

最终 ZIP 位于 `build/TimeFloat-macOS-<架构>.zip`。

## 目录

```text
Sources/TimeFloat/       AppKit 窗口、SwiftUI 界面、菜单与应用入口
Sources/TimeFloatCore/   时间格式、设置保存、窗口几何计算
Tests/TimeFloatCoreTests/ 核心逻辑测试
scripts/build-app.sh     Release 编译、打包和临时签名
scripts/generate-download-page.sh  按 Release 数据渲染下载页
docs/index.html          下载页模板
.github/workflows/       GitHub Actions 自动构建与发版
```
