# CLAUDE.md — 网文融合创作系统

## 项目概述

融合了 [webnovel-writer](https://github.com/lingfengQAQ/webnovel-writer)（RAG 记忆 + Story System + 追读力）和 [novel-writer-plugin](https://github.com/DankerMu/novel-writer-plugin)（去 AI 化 + 质量门控 + Spec-Driven）的长篇网文辅助创作系统。

## 核心能力

| 能力 | 来源 | 说明 |
|------|------|------|
| RAG 长记忆 | webnovel-writer | 向量检索 + BM25 回退，200 万字不遗忘 |
| Story System | webnovel-writer | 合同链机制，大纲即法律 |
| 去 AI 化 | novel-writer-plugin | 四层流水线 + 六层结构规则 + 12 种人性化技法 |
| 质量门控 | novel-writer-plugin | 十维评分 + 五档门控 + 双裁判 |
| 追读力 | webnovel-writer | Strand Weave 三线引擎 + Hard Invariants |

## 命令

| 命令 | 用途 |
|------|------|
| `/novel:init` | 深度初始化（7步交互 + 参考拆解 + 创意约束包） |
| `/novel:plan <卷号>` | 卷纲规划（节拍表→时间线→章纲→合同） |
| `/novel:write <章号>` | 12步写章流水线 |
| `/novel:review <范围>` | 十维审查 + 门控 |
| `/novel:query <关键词>` | 状态查询 |
| `/novel:learn <经验>` | 写入长期记忆 |
| `/novel:dashboard` | 可视化面板 |
| `/novel:doctor` | 项目体检 |
| `/novel:check <章节>` | Bug 自检（novel-bug-checker） |

## Agent 体系

| Agent | 模型 | 职责 |
|-------|------|------|
| WorldBuilder | Opus | 世界观 + L1/L2 + 风格指纹 + 创意约束 |
| PlotArchitect | Opus | 卷纲 + Strand Weave + L3/LS |
| ContextAgent | Sonnet | RAG 检索 + 创作任务书 |
| ChapterWriter | Sonnet | Phase 1 起草 + Phase 2 去 AI 润色 |
| Reviewer | Sonnet/Opus | 十维评分 + 门控 + 双裁判 |
| Summarizer | Haiku | 摘要 + 状态增量 + 串线 |
| DataAgent | Haiku | 实体提取 + 伏笔追踪 + 投影 |

## 目录结构

```
{小说项目}/
├── .story-system/      # 合同链（唯一真源）
├── .webnovel/          # 只读投影
├── 大纲/               # 总纲/卷纲/章纲
├── 设定集/              # 世界观/角色/势力
├── 正文/               # 章节文件
├── 审查报告/            # 审查结果
├── 风格/               # 去AI化配置
└── .claude/            # Agent + 命令定义
```

## 安装使用

1. 将本目录下的 `.claude/` 和 `templates/` 复制到你的小说项目根目录
2. 确保 Claude Code 已安装
3. 执行 `/novel:init` 开始

## 质量流程

每章写完后的标准流程：

```
/novel:check 正文/第X卷/chXXXX.md   → 修 Bug
/novel:review 正文/第X卷/chXXXX.md  → 评分门控
```

`/novel:check` 基于 [novel-bug-checker](https://github.com/bbroot/novel-bug-checker) 的分析框架，检查逻辑漏洞、角色一致性、伏笔回收、细节冲突。与 `/novel:review` 互补——前者找硬 Bug，后者评整体质量。

## 融合设计文档

详见项目目录下的设计文档。
