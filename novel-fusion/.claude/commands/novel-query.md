# /novel:query <关键词> — 状态查询

查询项目中的任何信息：角色、伏笔、关系、节奏、实体、写作进度等。

## 适用场景
- "某个伏笔的回收计划是什么？"
- "主角现在什么修为？"
- "第X章和第Y章之间有没有时间线矛盾？"
- "还有哪些伏笔没回收？"
- "XX角色最后一次出现是什么时候？"

## 数据来源
- `.webnovel/state.json` — 综合状态快照
- `.webnovel/index.db` — 实体索引
- `.webnovel/summaries/` — 章节摘要
- `.webnovel/memory_scratchpad.json` — 长期记忆

## 查询类型

### 角色查询
```
/novel:query 萧炎          # 查询"萧炎"的完整状态
/novel:query 主角 关系      # 查询主角的关系网络
/novel:query 反派 动态      # 查询反派当前动态
```

### 伏笔查询
```
/novel:query 伏笔          # 列出所有开放伏笔
/novel:query 伏笔 过期     # 列出过期未回收的伏笔
/novel:query F001          # 查询指定伏笔详情
```

### 节奏查询
```
/novel:query 节奏          # 查看三线分布状态
/novel:query Strand        # 查看各故事线进度
```

### 实体查询
```
/novel:query 物品 等级     # 查询所有物品按等级排列
/novel:query 势力          # 查询势力格局
/novel:query 能力 主角     # 查询主角的所有能力
```

### 进度查询
```
/novel:query 进度          # 查看写作进度
/novel:query 统计          # 查看总字数/章节数/平均评分
```

## 输出格式
结构化展示查询结果，支持表格和列表格式。
