# /novel:doctor — 项目体检

对项目进行全面诊断，检查文件完整性、数据库健康、RAG 就绪状态、依赖配置。

## 适用场景
- 写作出现异常时排查
- 定期健康检查
- 从备份恢复后验证
- 迁移项目后确认完整性

## 检查项目

### 1. 文件完整性
- [ ] 核心目录存在（`.story-system/` `.webnovel/` `大纲/` `设定集/` `正文/`）
- [ ] Story System 文件完整（seed.json / runtime/ / commits/ / audit.jsonl）
- [ ] 章节文件连续（正文/ 下章节编号无跳跃）
- [ ] 摘要文件与章节一一对应

### 2. 数据库健康
- [ ] index.db 可正常读写
- [ ] vectors.db 可正常读写
- [ ] JSON 文件格式正确（state.json / memory_scratchpad.json）
- [ ] 无孤儿记录（index.db 中有记录但对应章节不存在）

### 3. RAG 就绪
- [ ] Embedding API 配置状态
- [ ] Reranker API 配置状态
- [ ] vectors.db 与 summaries/ 同步状态
- [ ] 回退模式（BM25）可用

### 4. Story System 健康
- [ ] seed.json 格式正确
- [ ] runtime contracts 与章节一一对应
- [ ] CHAPTER_COMMIT 链完整
- [ ] audit.jsonl 无异常记录

### 5. 契约一致性
- [ ] L1 硬规则未被任何章节违反（快速扫描）
- [ ] L2 角色契约与角色状态一致
- [ ] L3 章节契约与正文 CBN/CEN 对齐
- [ ] 伏笔的 planted_ch 和 reaped_ch 引用有效

### 6. 备份状态
- [ ] 最近备份时间
- [ ] 备份完整性

## 使用示例
```
/novel:doctor                    # 全面体检
/novel:doctor --chapter 12      # 检查特定章节
/novel:doctor --rag              # 只检查 RAG 系统
/novel:doctor --fix              # 自动修复非破坏性问题
```

## 输出
- 诊断报告（通过/警告/错误）
- 每个检查项的状态
- 可自动修复的问题列表（--fix 模式下自动处理）
- 需要手动处理的问题列表

## 警告 vs 错误
- ⚠️ **警告**：不影响写作但建议修复（如摘要缺失、备份过期）
- ❌ **错误**：会阻碍写作流程（如 runtime contract 缺失、index.db 损坏）
