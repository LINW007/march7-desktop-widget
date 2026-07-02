# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

三月七主题桌面待办小挂件 — Electron frameless 透明窗口桌面小组件。

## 常用命令

```bash
# 启动应用
cd D:\1.Cc\widget && npx electron .

# 安装依赖
cd D:\1.Cc\widget && npm install
```

或者双击 `widget/launch.vbs`（静默启动，自动检查依赖）。

## 架构

```
widget/
├── main.js           # Electron 主进程
├── preload.js        # contextBridge，暴露 widgetAPI 到渲染进程
├── todo-widget.html  # 渲染进程（HTML + CSS + JS 全在一个文件）
├── launch.ps1        # PowerShell 启动脚本
├── launch.vbs        # VBS 静默启动包装
└── package.json
```

### 窗口双形态

- **收起态**：90×90px，半透明圆形气泡（`#bubble`），`-webkit-app-region: drag` 原生拖拽
- **展开态**：370×540px，待办卡片（`#card`），卡片头部也可拖拽

切换通过 IPC `expand` / `collapse`，主进程 `setBounds` 做动画过渡。

### 关键设计点

- **拖拽**：使用 CSS `-webkit-app-region: drag` 让系统原生处理，**不要**手动 IPC 移动窗口（会产生竞态导致窗口失控）
- **点击 vs 拖拽判断**：`mousedown` 记录坐标，`mousemove` 监测位移 >3px 标记为拖拽，`mouseup` 时无移动则视为点击打开卡片
- **窗口穿透**：`mainWindow.setIgnoreMouseEvents(false)` 确保小窗口始终可交互，`blur` 事件时再次确认
- **数据持久化**：`localStorage` 存储待办数据，key 为 `march7-todo-items`
- **透明窗口**：`transparent: true` + `frame: false`，背景 `rgba(255,255,255,0.001)` 拦截鼠标事件但对人眼不可见

### widgetAPI（preload 暴露）

- `expand()` / `collapse()` — 展开/收起窗口（`ipcRenderer.send`，异步）

### 样式主题

三月七角色配色：粉色 `#FFB2C5` / `#FF8FAE` + 蓝色 `#8EC8E8` / `#5BA0D0`，对应角色粉蓝异色瞳。CSS 变量定义在 `:root` 中。
