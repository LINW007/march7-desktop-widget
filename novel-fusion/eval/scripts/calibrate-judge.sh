#!/bin/bash
# calibrate-judge.sh — QualityJudge 校准脚本
# 计算 AI 评分与人工标注之间的 Pearson 相关系数

set -e

DATASET_DIR="${1:-eval/datasets}"
OUTPUT="eval/calibration-report.json"

echo "📊 QualityJudge 校准开始..."
echo "数据集目录: $DATASET_DIR"

# 统计样本数
SAMPLE_COUNT=$(find "$DATASET_DIR" -name "*.jsonl" -exec cat {} \; | wc -l)
echo "标注样本数: $SAMPLE_COUNT"

if [ "$SAMPLE_COUNT" -lt 30 ]; then
  echo "⚠️ 样本数不足 30，校准结果仅供参考（建议 ≥30 个样本）"
fi

# 计算 Pearson r（使用 Python）
python3 - "$DATASET_DIR" "$OUTPUT" << 'PYEOF'
import sys, json, os
from math import sqrt

dataset_dir = sys.argv[1]
output_path = sys.argv[2]

# 加载标注数据
annotations = []
for f in os.listdir(dataset_dir):
    if f.endswith('.jsonl'):
        with open(os.path.join(dataset_dir, f)) as fh:
            for line in fh:
                if line.strip():
                    annotations.append(json.loads(line))

if len(annotations) < 2:
    print("❌ 标注数据不足")
    sys.exit(1)

# 按章节分组，计算人工均值
from collections import defaultdict
human_scores = defaultdict(list)
for a in annotations:
    if a.get('annotator', '').startswith('human'):
        ch = a['chapter']
        for dim, score in a['scores'].items():
            human_scores[(ch, dim)].append(score)

# 计算 Pearson r
def pearson_r(xs, ys):
    n = len(xs)
    if n < 3: return None
    mx, my = sum(xs)/n, sum(ys)/n
    sx = sqrt(sum((x-mx)**2 for x in xs) / (n-1))
    sy = sqrt(sum((y-my)**2 for y in ys) / (n-1))
    if sx == 0 or sy == 0: return None
    return sum((x-mx)*(y-my) for x,y in zip(xs,ys)) / ((n-1)*sx*sy)

# 按维度计算
dimensions = ["plot_logic","character_ooc","consistency","style_naturalness",
              "immersion","pacing","cool_point_density","readability_pull",
              "foreshadowing","emotional_impact"]

results = {}
for dim in dimensions:
    human_means = {}
    for (ch, d), scores in human_scores.items():
        if d == dim:
            human_means[ch] = sum(scores) / len(scores)
    # AI scores would come from actual review runs
    # For now: output template
    results[dim] = {"human_mean": sum(human_means.values())/len(human_means) if human_means else None,
                    "sample_count": len(human_means)}

report = {
    "sample_count": len(annotations),
    "dimensions": results,
    "overall_pearson_r": None,  # 需要 AI 评分数据
    "threshold_suggestions": {
        "pass": 4.0,
        "repolish": 3.5,
        "revise": 3.0,
        "human_review": 2.0
    }
}

with open(output_path, 'w', encoding='utf-8') as f:
    json.dump(report, f, ensure_ascii=False, indent=2)

print(f"✅ 校准报告已生成: {output_path}")
PYEOF

echo "完成。"
