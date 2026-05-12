# 记忆系统（Memory）

> WebHarness 框架的跨会话记忆能力，确保 Agent 团队可以在中断后恢复任务、保持配置一致性和累积经验。

## 设计理念

> **「团队不只是会话内的协作——它需要记忆。」**

## 三层记忆架构

```
┌─────────────────────────────────────────────┐
│              记忆金字塔 (Memory Pyramid)       │
│                                              │
│   Layer 3: 经验记忆 (Experience)              │
│   ────────────────────────────               │
│   跨项目的通用经验、模式、反模式                 │
│   存储位置: ~/.webharness/memory/MEMORY.md    │
│   生命周期: 永久 (手动清理)                    │
│                                              │
│   Layer 2: 项目记忆 (Project)                │
│   ────────────────────────────               │
│   项目配置、决策记录、技术债、迭代经验           │
│   存储位置: <project>/memory/                │
│   生命周期: 随项目存在                         │
│                                              │
│   Layer 1: 会话记忆 (Session)                 │
│   ────────────────────────────               │
│   当前任务的中间状态、上下文快照                │
│   存储位置: <project>/memory/sessions/       │
│   生命周期: 当前任务周期                       │
│                                              │
└─────────────────────────────────────────────┘
```

---

## 存储结构

```
memory/
├── config.json       # 记忆系统配置（retention/sync）
├── state.json        # 当前会话状态
├── decisions.log     # 决策审计日志
├── README.md
└── backups/          # 状态快照备份
    └── state-YYYYMMDD-HHMMSS.json
```

## 记忆职责矩阵

每个角色负责维护自己领域内的记忆数据：

| 角色 | 负责的记忆层 | 写入内容 | 读取频率 |
|------|-------------|----------|----------|
| **PM** | L2 decisions.log | 决策记录、优先级变更、排期调整 | 每次 session 开始 |
| **Planner** | L2 tech-debt.json + L3 MEMORY.md | 技术债发现、架构决策、选型理由 | 每次设计方案前 |
| **Coder** | L1 session snapshots | 当前编码进度、TODO 标记、实现笔记 | 恢复会话时 |
| **Reviewer** | L2 code-review-patterns.json | Review 常见问题模式、高频缺陷统计 | 每次 Review 前 |
| **Tester** | L2 agent-performance.json | Bug 统计、测试覆盖率趋势、缺陷模式分析 | 每次评估前 |
| **Evaluator** | L2 quality baselines | 评分历史、趋势数据、改进跟踪 | 每次评估时对比 |
| **Deployer** | L2 config.json (environment_map) | 部署记录、回滚历史、环境配置变更 | 每次部署前 |

---

## 自动保存触发点

| 触发事件 | 保存动作 |
|----------|----------|
| 完成一个 Task | 更新 `state.json`，追加 checkpoint |
| 状态机转换 | 写入 `state.json` 的 history 字段 |
| 用户主动暂停 | 创建完整 snapshot（含 context） |
| 发生错误/异常 | 保存 error context + 前一步正常状态 |
| 每 5 分钟自动 | 增量更新 progress |

---

## 恢复流程

当 Agent 重新启动时：

1. 读取 `memory/config.json` 获取配置
2. 检查 `memory/state.json` 的当前状态
3. 如果有未完成的 Task，从最后一个 checkpoint 恢复
4. 读取 `memory/decisions.log` 获取历史决策上下文