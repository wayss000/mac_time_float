# TimeFloat

一个原生、离线运行的 macOS 悬浮时钟。支持 macOS 13 及以上，无账号、无服务器、无第三方依赖。

## 下载使用

1. 打开仓库的 **Actions → Build macOS app**，选择最新成功（绿色）的 `main` 构建。
2. 在页面底部 **Artifacts** 下载 `TimeFloat-macOS`，解压后选择对应版本：
   - `TimeFloat-macOS-arm64.zip`：Apple Silicon（M1/M2/M3/M4 等）。
   - `TimeFloat-macOS-x86_64.zip`：Intel Mac。
3. 解压内层 ZIP，将 `TimeFloat.app` 拖到“应用程序”，双击启动。

产物经过临时签名，但尚未使用 Apple Developer ID 签名或公证。如果系统阻止首次打开，在确认下载来源为本仓库后，前往“系统设置 → 隐私与安全性”选择“仍要打开”。

## 操作

- 拖动时钟卡片移动窗口；拖动四边或四个角调整大小，保持固定比例。鼠标移到边缘时光标变化，默认不显示操作按钮。默认 290 × 150pt，最小宽度 200pt，最大宽度 1200pt。升级后首次启动会将旧的大窗口缩小，之后保留你调整的尺寸。
- 点击系统菜单栏的时钟图标：显示/隐藏、切换 12/24 小时制、显示秒、置顶、背景浓度、恢复位置和退出。
- 时间使用系统本地时区；默认英文长日期（如 Friday, October 30）、显示秒、24 小时制和窗口置顶。监听系统时间、时区变化及唤醒事件刷新。
- 设置、窗口位置和大小自动保存在本机；拔掉外接屏幕后窗口会回到可见区域。
- 关闭 Dock 图标，通过菜单栏退出应用。默认深色圆角玻璃卡片；背景浓度控制玻璃上的黑色覆盖层，非整窗透明度。右键卡片也可访问操作菜单。
- 拖动或缩放结束后将窗口约束在有效可视区域；“恢复默认位置和大小”会回到主显示器。
- 置顶针对普通应用窗口；全屏 App 和独立 Space 的实际行为尚待在 Mac 上验证，不保证覆盖全屏。

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

## 自动构建

推送到 `main` 自动运行测试，分别编译 Apple Silicon 和 Intel 应用、验证签名与架构，保存 ZIP 到 Actions Artifacts，保留 30 天。也支持 Actions 页面手动运行和 PR 检查。构建失败不会上传产物。下载 Actions 产物需要登录 GitHub。

## 目录

```text
Sources/TimeFloat/       AppKit 窗口、SwiftUI 界面、菜单与应用入口
Sources/TimeFloatCore/   时间格式、设置保存、窗口几何计算
Tests/TimeFloatCoreTests/ 核心逻辑测试
scripts/build-app.sh     Release 编译、打包和临时签名
.github/workflows/       GitHub Actions 自动构建
```
