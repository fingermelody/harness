# 团队引擎（Build-Team）

> WebHarness 的多 Agent 编排核心。负责在项目初始化时组建团队、协调 7 个 Agent 协作、以及在任务卡住时进行恢复。

## 概述

`build-team` 是 WebHarness 的**团队编排层**，它不是一个 Agent 角色，而是一个**元技能（meta-skill）**——用来管理其他 Agent。

## 核心命令

### `build-team start` — 组建并启动团队

**使用场景**：项目初始化、开始一个新的 Feature 开发周期

```bash
# 基本用法
build-team start --project ./my-webapp --feature "用户认证模块"

# 指定角色子集
build-team start --agents planner,coder,tester --feature "API 优化"

# 从 checkpoint 恢复
build-team start --resume --checkpoint cp-3
```

### `build-team status` — 查看团队状态

```bash
# 查看所有 Agent 当前状态
build-team status

# 输出示例：
# ✅ Planner: IDEA 阶段 - 等待需求输入
# ⏳ Coder: 空闲
# ⏳ Tester: 空闲
# ⏳ Reviewer: 空闲
# ⏳ Deployer: 空闲
# ⏳ Evaluator: 空闲
```

### `build-team dispatch` — 分派任务

```bash
# 分派任务给单个 Agent
build-team dispatch --agent coder --task "实现用户登录 API"

# 分派任务给多个 Agent
build-team dispatch --agents coder,tester --task "实现+测试用户登录功能"
```

### `build-team checkpoint` — 创建检查点

```bash
# 创建当前状态快照
build-team checkpoint --name "v1.0.0-ready"

# 从检查点恢复
build-team restore --checkpoint v1.0.0-ready
```

---

## Agent 协作拓扑

```
                        ┌─────────┐
                        │   PM    │ ← 总协调 / 信息枢纽
                        └────┬────┘
                             │
          ┌──────────────────┼──────────────────┐
          ▼                  ▼                  ▼
    ┌──────────┐      ┌──────────┐      ┌──────────┐
    │ Planner  │─────→│  Coder   │─────→│ Reviewer │
    └──────────┘      └────┬─────┘      └────┬─────┘
                            │                 │
                            ▼                 ▼
                     ┌──────────┐      ┌──────────┐
                     │ Tester   │←─────│ Deployer │
                     └──────────┘      └──────────┘
                            │
                            ▼
                     ┌──────────┐
                     │Evaluator │
                     └──────────┘
```

---

## 工作流程

1. **PM** 接收需求，下达给 **Planner**
2. **Planner** 分析需求，输出方案 + 测试用例骨架
3. **Coder** 领取任务，TDD 实现
4. **Reviewer** 代码评审
5. **Deployer** 部署测试环境
6. **Tester** 执行 E2E 测试
7. **Evaluator** 综合评分
8. **PM** 审批生产发布
9. **Deployer** 部署生产
10. **Monitor** 监控上线