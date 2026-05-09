{
  "version": "1.0.0",
  "lastUpdated": "2026-05-09T04:19:00Z",
  "description": "WebHarness Memory System Documentation",
  "components": {
    "config": {
      "file": "config.json",
      "purpose": "Memory system configuration",
      "managedBy": "system"
    },
    "state": {
      "file": "state.json",
      "purpose": "Current session/project state",
      "managedBy": "agent"
    },
    "decisions": {
      "file": "decisions.log",
      "purpose": "Historical decision audit trail",
      "managedBy": "agent"
    },
    "backups": {
      "directory": "backups/",
      "purpose": "State snapshots for recovery"
    }
  },
  "workflow": {
    "sync": "每5分钟自动同步到 state.json",
    "checkpoint": "每个关键步骤后保存状态",
    "recovery": "启动时从最近备份恢复"
  },
  "retention": {
    "shortTerm": "会话级记忆 (7天)",
    "mediumTerm": "项目级记忆 (30天)",
    "longTerm": "跨项目经验 (90天)"
  }
}