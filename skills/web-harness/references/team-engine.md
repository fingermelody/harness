# WebHarness 团队引擎（Build-Team）

本文档定义了 `build-team` 技能——WebHarness 的多 Agent 编排核心。负责在项目初始化时组建团队、协调 6 个 Agent 协作、以及在任务卡住时进行恢复。

---

## 概述

`build-team` 是 WebHarness 的**团队编排层**，它不是一个 Agent 角色，而是一个**元技能（meta-skill）**——用来管理其他 Agent。

```
┌──────────────────────────────────────────────┐
│              build-team (团队引擎)              │
│                                               │
│   ┌────────┐ ┌────────┐ ┌────────┐           │
│   │ Planner│→→│ Coder  │→→│ Tester │           │
│   └───┬────┘ └───┬────┘ └───┬────┘           │
│       │          │          │                  │
│       ▼          ▼          ▼                  │
│   ┌────────┐ ┌────────┐ ┌────────┐           │
│   │Evaluator│←─│Deployer│  │   PM   │ (总调度)  │
│   └────────┘ └────────┘ └────────┘           │
│                                               │
│   + Memory System (状态持久化)                 │
│   + State Machine (流程控制)                   │
│   + Event Bus (消息总线)                       │
└──────────────────────────────────────────────┘
```

---

## 核心命令

### 1. `build-team start` — 组建并启动团队

**使用场景**：项目初始化、开始一个新的 Feature 开发周期

```bash
# 基本用法
build-team start --project ./my-webapp --feature "用户认证模块"

# 指定角色子集
build-team start --agents planner,coder,tester --feature "API 优化"

# 从 checkpoint 恢复
build-team start --resume --checkpoint cp-3
```

#### 执行流程

```
Phase 1: 初始化 (Init)
├── ① 检查 .memory/ 目录 → 不存在则创建
├── ② 加载 .memory/config.json → 注入项目上下文
├── ③ 加载 codebuddy.md → 注入团队规范
├── ④ 检查残留 session → 有则询问恢复/丢弃
└── ⑤ 创建新 session_id

Phase 2: 角色加载 (Load Agents)
├── ⑥ 读取 .agents/*.md → 加载 6 个角色定义
├── ⑦ 为每个 Agent 分配:
│   ├── 独立上下文窗口（含记忆数据）
│   ├── Prompt 模板（来自 agents.md）
│   └── 工具权限集（按角色限制）
└── ⑧ 注册 Agent 到 Team Registry

Phase 3: 任务分发 (Dispatch)
├── ⑨ PM 接收 feature 需求
├── ⑩ PM → Planner: "请设计方案"
├── ⑪ Planner 输出方案 → PM 审批
├── ⑫ PM → Coder: "按方案实现" (+ 方案文档)
├── ⑬ Coder 完成 → 自动触发 Tester
├── ⑭ Tester 完成 → 自动触发 Evaluator
├── ⑮ Evaluator 评分 → 通过则触发 Deployer
└── ⑯ Deployer 部署 → PM 确认 → 完成

Phase 4: 持续运行 (Run Loop)
├── 每 30s 检查 team health
├── 每个 Agent 完成任务时保存 snapshot
├── 状态转换时更新 state machine
└── 异常时进入 recovery mode
```

#### 启动输出示例

```
╔════════════════════════════════════════════╗
║     WebHarness Team Engine v1.0            ║
║                                            ║
║  Session: sess-20260508-001               ║
║  Feature: 用户认证模块                      ║
║  Status: 🟢 RUNNING                         ║
╠════════════════════════════════════════════╣
║  Agent        Status    Current Task       ║
║  ──────────── ────────  ────────────────   ║
║  🎩 PM         🔵 active   协调需求分析      ║
║  📐 Planner    🟡 waiting  接收需求...      ║
║  💻 Coder      ⚪ idle     等待分配...      ║
║  🧪 Tester     ⚪ idle     等待分配...      ║
║  📊 Evaluator  ⚪ idle     等待分配...      ║
║  🚀 Deployer   ⚪ idle     等待分配...      ║
╠════════════════════════════════════════════╣
║  State Machine: IDEA → PLAN (目标)          ║
║  Memory: .memory/sessions/sess-.../active   ║
║  Next: PM 正在向 Planner 下达需求...        ║
╚════════════════════════════════════════════╝
```

---

### 2. `build-team status` — 查看团队状态

查看当前团队的实时健康度：

```bash
build-team status [--verbose] [--session <id>]
```

#### 输出信息

| 字段 | 说明 |
|------|------|
| **team_status** | running / paused / error / completed |
| **session_id** | 当前会话 ID |
| **uptime** | 团队运行时长 |
| **state_machine** | 当前所处状态 + 历史 |
| **agent_statuses** | 各 Agent 的状态和当前任务 |
| **blocked_items** | 阻塞项列表（谁在等什么） |
| **checkpoints** | 可用的检查点列表 |
| **memory_health** | 记忆系统状态（文件完整性） |

#### 健康度评估指标

```yaml
team_health_score:  # 0-100
  agent_responsiveness: 30  # 各 Agent 是否正常响应
  task_progress: 25          # 整体任务推进是否顺畅
  memory_integrity: 20       # 记忆文件是否完整
  state_consistency: 15      # state machine 是否一致
  error_rate: 10             # 错误频率（反向）

# 判定标准
# 90-100: 🟢 Healthy — 正常运转
# 70-89:  🟡 Degraded — 有延迟但可用
# 50-69:  🟠 Warning — 部分阻塞
# < 50:   🔴 Critical — 需要干预
```

---

### 3. `build-team restart` — 重启/恢复团队

**使用场景**：任务卡住、会话中断、Agent 异常无响应

```bash
# 基本重启（从最后 checkpoint 恢复）
build-team restart

# 指定恢复到某个 checkpoint
build-team restart --checkpoint cp-3

# 仅重启某个卡住的 Agent
build-team restart --agent coder

# 强制重做当前步骤（丢弃当前进度）
build-team restart --force --step code
```

#### restart 执行流程

```
用户发起 restart
    ↓
① 读取 .memory/sessions/active.json
    ↓
② 分析当前状态
    ├── 有 active.json 且完整 → 提供 3 个选项
    ├── active.json 损坏 → 尝试读最近的 checkpoint
    └── 无任何记录 → 提示从头开始
    ↓
③ 展示诊断报告
    ╔═══════════════════════════════╗
    ║  🔴 团队已停止响应             ║
    ║                               ║
    ║  停止位置: CODE 阶段           ║
    ║  卡住 Agent: Coder            ║
    ║  最后活动: 2h 前              ║
    ║  最后 checkpoint: cp-3        ║
    ║  (JWT sign/verify 已完成)     ║
    ║                               ║
    ║  [A] 从 cp-3 恢复             ║
    ║  [B] 回退到 TEST 阶段重做      ║
    ║  [C] 全部重来                 ║
    ╚═══════════════════════════════╝
    ↓
④ 用户选择恢复策略
    ↓
⑤ 执行恢复
    ├── 恢复各 Agent 状态到 checkpoint 点
    ├── 恢复 state machine 位置
    ├── 重新注入记忆上下文
    └── 继续运行 loop
    ↓
⑥ Team Resumed ✅
```

#### 恢复策略详解

| 策略 | 适用场景 | 数据保留 | 风险 |
|------|----------|----------|------|
| **checkpoint 恢复** | 中断恢复、网络超时 | 保留至 checkpoint 的所有产出 | 低 — 精确回退 |
| **步骤级回退** | 某步骤结果不满意 | 保留前面所有步骤的产出 | 中 — 需重新执行该步 |
| **Agent 级重启** | 单个 Agent 卡死 | 其他 Agent 状态不变 | 低 — 只重启一个 |
| **全部重来** | 方向性错误 / 脏数据 | 清空 session，保留 L2 项目记忆 | 高 — 时间损失 |

---

### 4. `build-team pause` / `build-team resume` — 暂停与恢复

```bash
# 暂停（优雅停机）
build-team pause --reason "午餐休息"

# 恢复
build-team resume
```

pause 时执行：
1. 所有 Agent 完成当前原子操作后停止接受新任务
2. 保存完整 snapshot
3. 写入 `status: "paused"` 到 active.json
4. 释放计算资源

---

### 5. `build-team stop` — 停止团队

```bash
# 正常停止（完成任务后）
build-team stop --save

# 立即强制停止
build-team stop --force
```

stop 时执行：
1. 生成最终报告（完成了什么、做到哪了、下一步是什么）
2. 录档 session 到 archive/
3. 清理临时文件
4. 更新项目记忆（decisions.log、tech-debt.json）

---

## 团队事件总线（Event Bus）

Agent 之间通过事件总线通信，不直接耦合：

### 事件类型

```typescript
type TeamEvent =
  // 任务事件
  | { type: "task:assigned"; to: Agent; task: Task }
  | { type: "task:completed"; from: Agent; result: TaskResult }
  | { type: "task:blocked"; from: Agent; reason: string }
  | { type: "task:retry"; from: Agent; attempt: number }

  // 状态机事件
  | { type: "state:transition"; from: State; to: State }
  | { type: "state:rollback"; to: State; reason: string }

  // 记忆事件
  | { type: "memory:snapshot"; phase: string }
  | { type: "memory:checkpoint"; id: string }

  // 团队管理事件
  | { type: "team:health_update"; score: number }
  | { type: "team:error"; agent: Agent; error: Error }
  | { type: "team:recovery_started"; strategy: RecoveryStrategy };
```

### 事件流转示例

```
Planner 完成 → emit(task:completed)
                ↓
         PM 收到事件
                ↓
         PM 决定 → emit(task:assigned, to: Coder)
                ↓
         Coder 开始工作...
         Coder 遇到需求不明确 → emit(task:blocked, reason="API spec unclear")
                ↓
         PM 收到 blocked 事件
                ↓
         PM → emit(task:assigned, to: Planner, task="澄清 API spec")
                ↓
         Planner 补充文档 → emit(task:completed)
                ↓
         PM → 通知 Coder 继续
```

---

## 并行协作模式

### 流水线模式（默认）

最常用的模式——串行流水线：

```
PM → Planner → Coder → Tester → Evaluator → Deployer
```

适合：单一 Feature 开发，有明确先后依赖

### 扇出-扇入模式

当一个大 Feature 可以拆分为独立子任务时：

```
           ┌→ Coder-A ─→ Tester-A ─┐
PM → Planner ├→ Coder-B ─→ Tester-B ─┼→ Evaluator → Deployer
           └→ Coder-C ─→ Tester-C ─┘
```

适用条件：
- 子任务之间无代码冲突（不同模块/不同文件）
- 各子任务有独立的验收标准
- Evaluator 可以合并评估整体质量

### Review-修正循环模式

当 Evaluator 打回时：

```
Coder → Tester → Evaluator(BLOCK)
                        ↓ (emit feedback)
                     Coder(修复)
                        ↓
                     Tester(回归)
                        ↓
                     Evaluator(重评) → PASS → Deployer
```

---

## 与记忆系统的集成点

| 操作 | 记忆动作 |
|------|----------|
| `build-team start` | 创建 session，初始化 .memory/ |
| 每个 Task 完成 | 追加 checkpoint 到 active.json |
| 状态转换 | 写入 state-machine.history |
| Agent 产生决策 | 追加 decisions.log |
| 发现技术债 | 追加 tech-debt.json |
| `build-team pause` | 保存 snapshot |
| `build-team restart` | 读取最近 checkpoint 恢复 |
| `build-team stop` | 归档 session + 更新 L2 记忆 |

---

## 故障处理手册

### 场景 1：单个 Agent 死循环

**症状**: 某个 Agent 持续输出相似内容，progress_pct 不变

**诊断**: `build-team status` 显示该 Agent `last_activity` 超过阈值

**处理**:
```bash
build-team restart --agent <stuck-agent-name>
# 会自动回退到最后一个 checkpoint 后重试该 Agent 的当前任务
```

### 场景 2：循环依赖死锁

**症状**: A 等 B，B 等 A，team health 持续下降

**诊断**: 事件日志中出现多个 `task:blocked` 且互相引用

**处理**:
```bash
build-team status --verbose  # 查看 dependency graph
build-team restart --force --step <earliest_blocked_step>
# PM 会介入仲裁，打破循环依赖
```

### 场景 3：记忆文件损坏

**症状**: 读取 active.json 解析失败

**处理**:
1. 引擎自动检测 JSON 合法性
2. 尝试读取最近的 checkpoint 备份
3. 如果备份也损坏，提示用户选择：
   - 使用 `--force` 从头开始（保留 L2 项目记忆不受影响）
   - 手动编辑修复 JSON

### 场景 4：上下文溢出

**症状**: Agent 输入 token 超限，无法继续

**处理**:
1. 引擎自动触发 context compression（参考 ECC 的 strategic-compact）
2. 压缩策略：保留最近 N 轮对话 + 关键决策 + 当前任务上下文
3. 将压缩前的完整上下文存入 `.memory/sessions/[id]/context-full.md`

---

## 使用示例

### 示例 1：全新项目启动

```bash
# 1. 生成 harness 框架（已有 web-harness 技能完成）
/web-harness --project ./my-saas --stack nextjs+fastapi

# 2. 进入项目目录
cd my-saas

# 3. 组建团队，启动第一个 feature
build-team start --feature "用户注册+登录+JWT认证"

# → 团队自动运转：PM → Planner(方案) → Coder(实现) → Tester(测试) → Evaluator(评估) → Deployer(staging)

# 4. 中途查看进度
build-team status

# 5. 午休暂停
build-team pause --reason "lunch"

# 6. 下午恢复
build-team resume
```

### 示例 2：任务卡住恢复

```bash
# 昨天跑到一半断了，今天来恢复
cd my-saas

# 检查状态
build-team status
# → 显示: paused at CODE phase, Coder stuck at middleware.ts

# 恢复
build-team restart
# → 弹出选项: [A]cp-3恢复 [B]回退TEST [C]重来
# → 选择 A，从中断点继续
```

### 示例 3：只启动部分角色做 Code Review

```bash
# 不需要全流程，只想做个深度 review
build-team start \
  --agents evaluator,coder \
  --mode review \
  --target "src/features/payment/"
```

这会跳过 PM/Planner/Tester/Deployer，仅用 Evaluator + Coder 做 review 模式。
