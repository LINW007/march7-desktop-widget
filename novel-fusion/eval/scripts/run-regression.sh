#!/bin/bash
# run-regression.sh — 回归测试脚本
# 对一批章节运行 Reviewer 并统计合规率和评分分布

set -e

CHAPTER_RANGE="${1:-1-10}"
OUTPUT="eval/regression-report.json"

echo "📊 回归测试开始..."
echo "章节范围: $CHAPTER_RANGE"

# 解析章节范围
IFS='-' read -r START END <<< "$CHAPTER_RANGE"
START=${START:-1}
END=${END:-10}

PASS_COUNT=0
TOTAL=0
SCORES=()

for ((ch=START; ch<=END; ch++)); do
  CHAPTER_FILE="正文/第1卷/ch$(printf '%04d' $ch).md"
  if [ -f "$CHAPTER_FILE" ]; then
    TOTAL=$((TOTAL + 1))
    echo "  审查第${ch}章..."
    # 实际运行时调用 Claude Code 的 /novel:review
    # 这里输出模板
    SCORE=3.8  # 占位，实际会从审查报告中提取
    SCORES+=("$SCORE")
    if [ "$(echo "$SCORE >= 4.0" | bc -l 2>/dev/null || echo 0)" -eq 1 ]; then
      PASS_COUNT=$((PASS_COUNT + 1))
    fi
  else
    echo "  ⚠️ 第${ch}章不存在，跳过"
  fi
done

COMPLIANCE_RATE=$(echo "scale=1; $PASS_COUNT * 100 / $TOTAL" | bc 2>/dev/null || echo "N/A")

# 计算均值和标准差（使用 Python）
python3 - "$TOTAL" "${SCORES[@]}" "$OUTPUT" "$COMPLIANCE_RATE" << 'PYEOF'
import sys, json

total = int(sys.argv[1])
scores = [float(s) for s in sys.argv[2:2+total]]
output = sys.argv[2+total]
compliance = sys.argv[3+total]

mean_score = sum(scores) / len(scores) if scores else 0
variance = sum((s - mean_score)**2 for s in scores) / len(scores) if scores else 0
std_dev = variance ** 0.5

report = {
    "chapters_tested": total,
    "compliance_rate": float(compliance.replace('%','')) / 100 if compliance != 'N/A' else None,
    "mean_score": round(mean_score, 2),
    "std_dev": round(std_dev, 2),
    "score_distribution": {
        "excellent_4plus": len([s for s in scores if s >= 4.0]),
        "good_3.5-3.9": len([s for s in scores if 3.5 <= s < 4.0]),
        "fair_3.0-3.4": len([s for s in scores if 3.0 <= s < 3.5]),
        "poor_below_3": len([s for s in scores if s < 3.0])
    },
    "dimension_breakdown": {
        "note": "需要实际审查数据，运行 /novel:review 批量审查后自动填充"
    }
}

with open(output, 'w', encoding='utf-8') as f:
    json.dump(report, f, ensure_ascii=False, indent=2)

print(f"\n📊 回归报告:")
print(f"  章节数: {total}")
print(f"  合规率: {compliance}%")
print(f"  均分: {mean_score:.1f}")
print(f"  标准差: {std_dev:.2f}")
print(f"  >=4.0: {report['score_distribution']['excellent_4plus']}")
print(f"  3.5-3.9: {report['score_distribution']['good_3.5-3.9']}")
print(f"  3.0-3.4: {report['score_distribution']['fair_3.0-3.4']}")
print(f"  <3.0: {report['score_distribution']['poor_below_3']}")
print(f"✅ 报告已保存: {output}")
PYEOF

echo "完成。"
