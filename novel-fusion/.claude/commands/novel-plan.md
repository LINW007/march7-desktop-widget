# /novel:plan <卷号> — 卷纲规划

基于总纲为指定卷生成完整的章纲规划。

## 适用场景
- 开始新一卷前的规划
- 已有总纲，需要拆解为具体章纲
- 之前的章纲用完了，需要规划下一批

## 前置条件
- `/novel:init` 已完成
- `大纲/总纲.md` 存在
- `.story-system/seed.json` 存在

## 执行流程

调用 **PlotArchitect Agent**，执行 10 步规划：

```
Step 1: 加载基线数据
Step 2: 补齐设定基线
Step 3: 确定卷范围与核心冲突
Step 4: 生成卷节拍表
Step 5: 生成卷时间线
Step 6: Strand Weave 节奏分配
Step 7: 爽点密度规划
Step 8: 批量生成章纲（10 章/批）
Step 9: 增量写回设定 + 验证
Step 10: 刷新 Story System 合同
```

### 产出文件
- `大纲/第N卷-节拍表.md`
- `大纲/第N卷-时间线.md`
- `大纲/第N卷-详细大纲.md`
- `.story-system/runtime/ch{XXXX}.json`（每章一份）
- `大纲/storylines.json`（更新）

## 使用示例
```
/novel:plan 1        # 规划第一卷
/novel:plan 2        # 规划第二卷
```

## 约束
- 10 章一批（复杂题材降为 8 章/批）
- 每章必须包含：目标/阻力/代价/时间锚点/CBN/CPNs/CEN/禁区
