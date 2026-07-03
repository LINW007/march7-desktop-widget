# CLAUDE.md — 网文融合创作系统

## 项目概述

融合了 [webnovel-writer](https://github.com/lingfengQAQ/webnovel-writer)（RAG 记忆 + Story System + 追读力）和 [novel-writer-plugin](https://github.com/DankerMu/novel-writer-plugin)（去 AI 化 + 质量门控 + Spec-Driven）的长篇网文辅助创作系统。

## 核心能力

| 能力 | 来源 | 说明 |
|------|------|------|
| RAG 长记忆 | webnovel-writer | 向量检索 + BM25 回退，200 万字不遗忘 |
| Story System | webnovel-writer | 合同链机制，大纲即法律 |
| 去 AI 化 | novel-writer-plugin | 六层结构规则 + 12 种人性化技法 |
| 质量门控 | novel-writer-plugin | 十二维评分 + 五档门控 + 双裁判 |
| 追读力 | webnovel-writer | Strand Weave 三线引擎 + Hard Invariants |

---

## 三稿分层架构

本系统将创作流程分为三个独立阶段，每阶段使用不同的 Agent 组合。

### 基础设施（永远在线，每章都跑）

| Agent | 模型 | 时机 | 职责 |
|-------|------|------|------|
| **ContextAgent** | Sonnet | 写前 | RAG 检索 + 组装创作任务书（前文摘要/角色状态/开放伏笔/风格参数） |
| **Summarizer** | Haiku | 写后 | 章节摘要 + 状态增量 + 串线检测 |
| **DataAgent** | Haiku | 写后 | 实体提取 + 伏笔追踪 + 索引更新 |

这三个是**记忆系统**——不参与质量判断，只负责"写前知道该知道什么，写后记住发生了什么"。任何一稿都不可移除。

### 初稿：快速铺量

**目标**：把故事从零写到纸上。允许粗糙。速度优先。

| Agent | 模型 | 每章都跑？ | 职责 |
|-------|------|-----------|------|
| **PlotArchitect** | Opus | 每 8-10 章跑一次 | 批量生成章纲 + L3 契约 + Strand 分配 |
| **FastDrafter** | Sonnet | 按需（仅当由 AI 起草时） | 精简版 ChapterWriter——只做 Phase 1 起草 + CBN/CPN/CEN 完整性，砍掉全部去 AI 化 |
| **OutlineSupervisor** | Sonnet | ✅ 每章 | 章纲→正文对齐验证：节点覆盖/禁区/Strand/伏笔 |
| **CostLedger** | Sonnet | ✅ 每章（快速模式） | 代价物理进展 + 烙印状态 + 记忆空白 + 硬抄本 + 烙印交互。只记账不评分 |
| **PaceEditor** | Sonnet | ✅ 每章（轻量模式） | 快速扫读流畅度——只查阻塞级卡点（信息过载/呼吸缺失），不查微观节奏 |

**不需要的**：Reviewer（评分太慢）、CharacterDeepener（角色弧光在二稿才追踪）、ProseScholar（初稿不雕琢文笔）、ChiefEditor（没有足够多的诊断报告需要裁决）、BetaReader（太早）、ContinuityAuditor（初稿只靠 PaceEditor 做基本检查）

**初稿流水线**：
```
PlotArchitect（批次规划章纲）
    ↓
ContextAgent（组装任务书）
    ↓
[作者写作 或 FastDrafter 起草]
    ↓
CostLedger（快速模式·更新代价账本）
    ↓
OutlineSupervisor（章纲对齐验证）→ 偏离则修订
    ↓
PaceEditor（轻量模式·只查阻塞卡点）
    ↓
Summarizer + DataAgent（摘要+实体提取）
```

### 二稿：深度修订

**目标**：重新编排信息释放节奏、场景呼吸、角色弧光、文笔质感。这是四个审视维度（信息坡度/场景节奏/声音一致性/伏笔可见性）落地的地方。

| Agent | 模型 | 每章都跑？ | 职责 |
|-------|------|-----------|------|
| **CostLedger** | Sonnet | ✅ 每章（完整模式） | 完整代价审计——逐行精读，五项全查。跑在最前面，给后面所有 Agent 提供基线 |
| **ContinuityAuditor** | Sonnet | ✅ 每章 | 跨章时间/空间/状态/钩子/物品连续性 + 状态快照维护。钩子链不能断 |
| **PaceEditor** | Sonnet | ✅ 每章 | 逐段检测：信息密度/呼吸段/句长单调/场景过渡/对话叙述交替/曝光时机 |
| **Reviewer** | Sonnet/Opus | ✅ 每章 | 十二维评分 + 阻塞检测 + 五档门控（≥4.0通过/≥3.5二次润色/≥3.0自动修订/≥2.0暂停/<2.0强制重写） |
| **CharacterDeepener** | Sonnet | ✅ 每章 | 主角弧光推进 + 配角活跃度 + 情感层次 + 成长里程碑 + 深化机会 |
| **ProseScholar** | Sonnet | ✅ 每章 | **直接动手改句子**：潜台词/意象/呼吸/两面性/场面视角。唯一被允许改正文的 Agent |
| **OutlineSupervisor** | Sonnet | ✅ 每章 | 重新验证——修订后是否偏离了章纲？ |
| **ChiefEditor** | Opus | ✅ 每章 | 汇总所有报告 → 逐条裁决改/不改 → 排优先级 → 给 ProseScholar 发执行指令 |
| **ThemeArchitect** | Sonnet | 每 10 章一次 | 检查主题在人物/情节/世界观中的锚定是否还在 |
| **WorldViewer** | Sonnet | 每 10 章一次 | 对标大火网文查世界观结构缺漏（来源/能力/代价/组织/主题锚定） |
| **NovelDistiller** | Sonnet | 偶尔 | 蒸馏参考作品的结构模式，校准设定释放节奏 |

**二稿流水线**：
```
CostLedger（完整模式·更新代价账本）
    ↓
ContinuityAuditor（跨章连续性+钩子链）
    ↓
PaceEditor（逐段流畅度）
    ↓
Reviewer（十二维评分+门控）→ 阻塞则标记
    ↓
CharacterDeepener（角色弧光+深化建议）
    ↓
ChiefEditor（汇总全部报告→裁决→优先级排序）
    ↓
ProseScholar（执行修改） + OutlineSupervisor（验证修改后章纲对齐）
    ↓
Summarizer + DataAgent（摘要+实体提取）

每10章插入：ThemeArchitect + WorldViewer 检查点
```

### 终稿：读者就绪

**目标**：这稿之后就要发了。不允许任何阻塞问题。

| Agent | 模型 | 每章都跑？ | 职责 |
|-------|------|-----------|------|
| **Reviewer** | Sonnet + Opus | ✅ 每章 | 双裁判模式（关键章两模型独立评分取均值），门控标准提高到 ≥4.0 |
| **BetaReader** | Sonnet | ✅ 每章 | **不看任何设定文件**，像真实读者一样翻开正文→只报告走神点/眼亮点/回读点 |
| **ChiefEditor** | Opus | ✅ 每章 | 最终裁决——Reviewer 和 BetaReader 打架时**优先信 BetaReader** |
| **ContinuityAuditor** | Sonnet | ✅ 每章 | 最终连续性确认 |
| **CostLedger** | Sonnet | ✅ 每章（完整模式） | 最终代价账本审计 |
| **ProseScholar** | Sonnet | 按需 | 只改 BetaReader 标记为"走神"的段落 |

**终稿流水线**：
```
CostLedger（完整模式）→ ContinuityAuditor（连续性确认）
    ↓
Reviewer（双裁判）+ BetaReader（盲读）→ 并行
    ↓
ChiefEditor（最终裁决——BetaReader优先）
    ↓
ProseScholar（只修走神点·最后一刀）
    ↓
Summarizer + DataAgent
```

---

## 完整 Agent 清单（19个）

### 冷启动（仅一次）
| # | Agent | 模型 | 职责 |
|----|-------|------|------|
| 1 | **WorldBuilder** | Opus | 世界观 + L1/L2 + 风格指纹 + 创意约束 |

### 基础设施（永远在线）
| # | Agent | 模型 | 职责 |
|----|-------|------|------|
| 2 | **ContextAgent** | Sonnet | RAG检索 + 创作任务书 |
| 3 | **Summarizer** | Haiku | 章节摘要 + 状态增量 + 串线 |
| 4 | **DataAgent** | Haiku | 实体提取 + 伏笔追踪 + 投影 |

### 初稿层
| # | Agent | 模型 | 职责 |
|----|-------|------|------|
| 5 | **PlotArchitect** | Opus | 卷纲 + Strand Weave + 章纲 + L3/LS 契约 |
| 6 | **FastDrafter** | Sonnet | 🆕 精简起草——只做 Phase 1，砍掉全部去 AI 化。初稿专用 |
| 7 | **OutlineSupervisor** | Sonnet | 章纲执行验证 + 节点覆盖 + 偏离检测 + Strand 走线 |
| 8 | **CostLedger** | Sonnet | 🆕 代价/烙印物理账本——每章强制更新。本书专属 |

### 二稿层
| # | Agent | 模型 | 职责 |
|----|-------|------|------|
| 9 | **ContinuityAuditor** | Sonnet | 🆕 跨章连续性（时间/空间/状态/钩子/物品）+ 状态快照 |
| 10 | **PaceEditor** | Sonnet | 逐段流畅度 + 信息密度 + 呼吸节奏 + 场景过渡 |
| 11 | **Reviewer** | Sonnet/Opus | 十二维评分 + 五档门控 + 双裁判 |
| 12 | **CharacterDeepener** | Sonnet | 跨章角色弧光追踪 + 成长性检测 + 扁平化预警 |
| 13 | **ProseScholar** | Sonnet | 文学技法升级——直接改正文（潜台词/意象/呼吸/两面性/场面） |
| 14 | **ChiefEditor** | Opus | 汇总裁决 + 优先级排序 + 最终修改决策 |
| 15 | **ThemeArchitect** | Sonnet | 主题锚定审视——主题在人物/情节/世界观中是否一致 |
| 16 | **WorldViewer** | Sonnet | 世界观结构审视——对标大火网文找缺漏 |
| 17 | **NovelDistiller** | Sonnet | 蒸馏大火网文结构模式——对标分析 |

### 终稿层
| # | Agent | 模型 | 职责 |
|----|-------|------|------|
| 18 | **BetaReader** | Sonnet | 盲读测试——不看设定，只报告走神/眼亮/回读 |

> **注**：终稿层复用二稿层的 Reviewer(双裁判模式)、ChiefEditor、ContinuityAuditor、CostLedger、ProseScholar(按需)。

---

## Skill 触发时机

以下 skill 由 Claude 根据当前阶段**自动判断**是否该触发，不需要作者手动调度：

| Skill | 触发条件 | 调用什么 |
|-------|---------|---------|
| **`/novel:init`** | 项目目录下无 `.story-system/seed.json` 或设定集为空 | WorldBuilder（7步交互+生成全部设定） |
| **`/novel:plan <卷号>`** | 每写完 8-10 章，或开始新一卷时 | PlotArchitect（批量生成章纲+Strand分配+L3契约） |
| **`/novel:write <章号>`** | 作者说"写第X章"，且当前处于初稿阶段 | 初稿流水线（ContextAgent→FastDrafter→OutlineSupervisor→CostLedger→PaceEditor→Summarizer+DataAgent） |
| **`/novel:revise <范围>`** | 作者说"二稿"/"修订"，或初稿完成一个批次后 | 二稿流水线（CostLedger→ContinuityAuditor→PaceEditor→Reviewer→CharacterDeepener→ChiefEditor→ProseScholar+OutlineSupervisor） |
| **`/novel:polish <范围>`** | 作者说"终稿"/"定稿"/"发布了" | 终稿流水线（CostLedger→ContinuityAuditor→Reviewer双裁判+BetaReader并行→ChiefEditor→ProseScholar按需） |
| **`/novel:review <范围>`** | 作者单独想审一章（不属于三稿流程中的自动触发） | Reviewer 单次审查 |
| **`/novel:check <章节>`** | 作者想快速检查 Bug | ContinuityAuditor + CostLedger 快速审计 |
| **`/novel:dashboard`** | 作者想问"写到哪了/状态怎么样" | 汇总 Summarizer + CostLedger + ContinuityAuditor 的最新快照 |
| **`/novel:doctor`** | 项目感觉不对劲，做全面体检 | WorldViewer + ThemeArchitect（世界观+主题层面全检） |
| **`/novel:learn <经验>`** | 作者说"记住……"或发现了一个值得记录的规律 | 写入长期记忆 |

### Claude 自动判断规则

1. **写了新章节后**：如果章节数 ≤ 5 → 自动跑初稿流水线。如果章节数 > 5 且作者没说过"二稿" → 提醒"初稿已写N章，可以考虑开始二稿了"
2. **作者明确说"二稿"**：自动切换到二稿流水线，逐章运行。每 10 章插入 ThemeArchitect + WorldViewer
3. **作者说"终稿/定稿/发布了"**：自动切换到终稿流水线
4. **每写完 10 章**：提醒是否需要运行 `/novel:plan` 规划下一批章纲
5. **项目开始时**：如果检测到 `.story-system/seed.json` 不存在 → 自动建议 `/novel:init`

---

## 目录结构

```
{小说项目}/
├── .story-system/         # 合同链（唯一真源）
│   ├── seed.json
│   └── runtime/ch{XXXX}.json
├── .webnovel/             # 只读投影 + 运行状态
│   ├── state.json
│   ├── continuity_snapshot.json   # 🆕 ContinuityAuditor 维护
│   ├── cost_ledger.json           # 🆕 CostLedger 维护
│   ├── summaries/
│   └── index.db
├── 大纲/                  # 总纲/卷纲/章纲
├── 设定集/                # 世界观/角色/势力
├── 正文/                  # 章节文件
├── 审查报告/              # 审查结果
├── 风格/                  # 去AI化配置
└── .claude/
    ├── agents/            # Agent 定义（19个）
    └── CLAUDE.md          # 本文件
```

---

## 质量流程（按阶段）

### 初稿阶段
```
写一章 → CostLedger(快速) → OutlineSupervisor → PaceEditor(轻量) → 修阻塞问题 → 下一章
```
每章目标：情节正确 + 章纲对齐 + 没有阻塞级阅读卡点。文笔和角色弧光不管。

### 二稿阶段
```
CostLedger(完整) → ContinuityAuditor → PaceEditor → Reviewer → CharacterDeepener → ChiefEditor → ProseScholar改 + OutlineSupervisor验
```
每章目标：信息坡度合理 + 场景节奏流畅 + 角色有成长 + 代价追踪一致 + 文笔冷感到位。

每 10 章额外插入 ThemeArchitect + WorldViewer。

### 终稿阶段
```
CostLedger(完整) → ContinuityAuditor → Reviewer(双裁判) || BetaReader(盲读) → ChiefEditor → ProseScholar(只修走神点)
```
每章目标：读者拿起来放不下。走神点归零。

---

## 本书专属约束

以下约束在所有阶段自动生效，所有 Agent 都必须遵守：

1. **烙印共振硬规则**：真正共振在 ch0015 解锁。ch0015 之前只能用"各自"描述烙印间关系——禁止"互振/通信/共有/共振/那根线连接"
2. **冷感文笔**：短句为主。感官锚点（凉/痒/白色/振动）。情感克制——不写"他很难过"，写身体反应
3. **代价可视化**：每 1-2 章必须有一处代价物理进展的描写（白色/旧疤/硬抄本褪色/记忆闪白）——CostLedger 会追踪这个频率
4. **信息释放节奏**：第一卷只揭示"规则可改写+代价是遗忘+烙印有基础能力"。核心秘密（一级书写者/书写者碎片/代价回收）分六卷逐步释放
