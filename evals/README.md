# WebHarness 评估报告

## 报告结构

```
reports/
└── YYYY-MM/
    └── eval-YYYY-MM-DD-HHMMSS.json
```

## 报告格式

```json
{
  "reportId": "eval-2026-05-09-120000",
  "timestamp": "2026-05-09T12:00:00Z",
  "duration": 120,
  "dimensions": [
    {
      "id": "code-quality",
      "score": 95,
      "status": "excellent",
      "metrics": [...]
    }
  ],
  "overallScore": 92,
  "overallStatus": "excellent",
  "recommendations": [...],
  "delta": {
    "vsBaseline": +2,
    "vsPrevious": +1
  }
}
```

## 生成方式

```bash
# 运行完整评估
npm run eval

# 查看最新报告
cat reports/latest/eval.json

# 对比基线
npm run eval:compare
```