---
name: web-harness
description: >
  WebHarness 多智能体协作框架初始化器。为 Web 应用项目生成多 Agent 团队、启动状态机工作流、
  初始化 rules/hooks 配置。完成后等待用户输入需求，禁止自动生成任务。
  包含 7 个核心角色(planner/coder/reviewer/evaluator/deployer/tester/pm)、
  11 状态工作流(IDEA→PLAN→TEST-PLAN→CODE→REVIEW→DEPLOY-TEST→TEST-RUN→EVAL→DEPLOY-PROD→MONITOR→ARCHIVE)、
  分派规则、Git 钩子、质量门禁。
  触发词：web-harness、初始化框架、生成 harness、建团队、build-team、多 agent 协作。
agent_created: true
---

# Web-Harness: 多智能体协作框架初始化器

## 概述

本技能完成 5 件事：**创建团队 → 启动状态机 → 对接记忆文件 → 初始化配置 → 等待用户输入**。

框架基于 TDD 驱动 + 测试后置 + Review 门禁，专为 WebApp 场景定制。

## 何时使用

- 用户说「初始化框架」「生成 harness」「建团队」「多 agent 协作」
- 项目需要标准化的多 Agent 协作开发流程
- 团队希望用状态机驱动开发节奏

---

## 执行流程

### 第一步：确认项目信息

向用户确认以下信息：

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `project_path` | 项目根目录 | 当前工作目录 |
| `tech_stack` | 技术栈 | 需询问 |

### 第二步：创建团队（TeamCreate）→ 项目级持久化

**核心原则：团队配置属于项目，不属于用户。**

#### 2.1 使用 TeamCreate 创建运行时团队

使用 TeamCreate 创建团队，然后按 `agents/` 目录下的模板 spawn 7 个 Agent：

```
TeamCreate → "harness-team"

Spawn Agents:
  pm:        读取 agents/pm.md       → Agent(name="pm", prompt=角色定义内容)
  planner:   读取 agents/planner.md   → Agent(name="planner", prompt=角色定义内容)
  coder:     读取 agents/coder.md     → Agent(name="coder", prompt=角色定义内容)
  reviewer:  读取 agents/reviewer.md  → Agent(name="reviewer", prompt=角色定义内容)
  tester:    读取 agents/tester.md    → Agent(name="tester", prompt=角色定义内容)
  evaluator: 读取 agents/evaluator.md → Agent(name="evaluator", prompt=角色定义内容)
  deployer:  读取 agents/deployer.md  → Agent(name="deployer", prompt=角色定义内容)
```

每个 Agent 的 prompt 构造方式：
1. 读取对应的 `agents/{role}.md` 文件
2. 提取定位、核心职责、Prompt 模板部分
3. 组合为完整 prompt 传入 Agent

#### 2.2 同步团队配置到项目级

TeamCreate 运行时配置存放在 `~/.workbuddy/teams/`（平台行为，不可改）。
创建完成后，**立即将团队配置同步到项目级目录**：

```bash
mkdir -p {project_path}/.codebuddy/teams/
cp ~/.workbuddy/teams/harness-team/config.json {project_path}/.codebuddy/teams/harness-team.json
```

**项目级团队配置路径：**

```
项目根目录/.codebuddy/
├── teams/
│   └── harness-team.json    ← 团队配置（成员、角色、ID）
├── rules/
├── agents/
├── hooks/
├── ...
```

**为什么要项目级持久化：**
- 团队配置随项目走，不依赖特定用户环境
- 多人协作时可共享团队定义
- 中断恢复时优先读取项目级配置
- git 可追踪团队变更历史

**恢复场景：** 当检测到 `{project_path}/.codebuddy/teams/harness-team.json` 已存在时，读取其中的成员信息，避免重复创建。

### 第三步：启动状态机

初始化状态为 `IDEA`，按以下 11 状态工作流驱动：

```
IDEA → PLAN → TEST-PLAN → CODE → REVIEW → DEPLOY-TEST → TEST-RUN → EVAL → DEPLOY-PROD → MONITOR → ARCHIVE
```

**状态定义：**

| 状态 | 说明 | 主导角色 |
|------|------|----------|
| `IDEA` | 需求收集与分析 | PM + Planner |
| `PLAN` | 技术方案 + TDD 测试计划 | Planner |
| `TEST-PLAN` | 测试用例骨架输出 | Tester |
| `CODE` | TDD 驱动编码(RED→GREEN→REFACTOR) | Coder |
| `REVIEW` | 6维度代码审查(BLOCK机制) | Reviewer |
| `DEPLOY-TEST` | 部署测试环境 | Deployer |
| `TEST-RUN` | E2E + 回归测试 | Tester |
| `EVAL` | 质量评分(0-100) | Evaluator |
| `DEPLOY-PROD` | 生产发布(需PM审批) | Deployer + PM |
| `MONITOR` | 线上监控 | Deployer + PM |
| `ARCHIVE` | 版本归档 | 全员 |

**转换守卫规则：**

| 转换 | 前置条件 |
|------|----------|
| IDEA→PLAN | PM 录入需求 + AC 明确 + 技术可行性确认 |
| PLAN→TEST-PLAN | 技术方案完成(≥2备选) + API 契约定义 + Story 拆解 |
| TEST-PLAN→CODE | 测试用例骨架输出 + 联合评审通过 |
| CODE→REVIEW | 所有测试 GREEN + 覆盖率≥80% + Lint 通过 |
| REVIEW→DEPLOY-TEST | 6维度全 PASS |
| REVIEW→CODE | 任一维度 BLOCK → 回退修复 |
| DEPLOY-TEST→TEST-RUN | Health Check + Smoke Test 通过 |
| TEST-RUN→EVAL | E2E 100% 通过 + 无 P0 Bug |
| TEST-RUN→CODE | 发现 Bug → 修复重部署 |
| EVAL→DEPLOY-PROD | 评分≥80 + PM 确认 + 回滚方案就绪 |
| EVAL→CODE | 评分<60 BLOCK → 打回重构 |
| DEPLOY-PROD→MONITOR | 生产 Health Check + 业务指标正常 |
| MONITOR→IDEA | 新迭代需求 |
| MONITOR→ARCHIVE | 项目结项 |

**状态流转驱动逻辑：**

```
state = "IDEA"
收到用户需求后:
  IDEA → dispatch(pm, "澄清需求") → PLAN
  PLAN → dispatch(planner, "设计方案+测试骨架") → TEST-PLAN
  TEST-PLAN → dispatch(tester, "输出测试用例骨架") → CODE
  CODE → dispatch(coder, "TDD实现") → REVIEW
  REVIEW → dispatch(reviewer, "6维度Review")
    BLOCK → CODE (回退)
    PASS → DEPLOY-TEST
  DEPLOY-TEST → dispatch(deployer, "部署测试环境") → TEST-RUN
  TEST-RUN → dispatch(tester, "E2E测试")
    有Bug → CODE (回退)
    全通过 → EVAL
  EVAL → dispatch(evaluator, "质量评分")
    <60 → CODE | 60-79 → TEST-RUN | ≥80 → DEPLOY-PROD
  DEPLOY-PROD → dispatch(pm,"审批") + dispatch(deployer,"生产部署") → MONITOR
```

### 第四步：对接记忆文件，读取任务进度

检查项目的记忆文件，判断是全新启动还是恢复中断任务：

**读取路径：**

```
项目根目录/.codebuddy/memory/
├── state.json        ← 当前工作流状态（currentState / completedSteps / tasks）
├── decisions.log     ← 历史决策记录
└── config.json       ← 环境配置（environment_map）
```

**判断逻辑：**

```
1. 读取 state.json
2. if state.json.workflow.currentState != null:
     → 有未完成任务，恢复模式
   else:
     → 全新启动模式

恢复模式：
  - 从 state.json.workflow.currentState 恢复状态机位置
  - 从 state.json.tasks.inProgress 恢复进行中的任务
  - 从 decisions.log 读取历史决策上下文
  - 通知用户："检测到未完成任务 [X]，当前状态 [S]，是否继续？"

全新启动模式：
  - 初始化 state.json 为默认值
  - 状态机从 IDEA 开始
```

**state.json 关键字段：**

```json
{
  "workflow": {
    "currentPhase": "CODE | REVIEW | ...",
    "currentState": "IDEA → PLAN → ... 当前位置",
    "completedSteps": ["IDEA", "PLAN", "TEST-PLAN"]
  },
  "tasks": {
    "pending": ["task-id-1"],
    "inProgress": ["task-id-2"],
    "completed": ["task-id-3"]
  }
}
```

**每次状态转换时同步写入 state.json**，确保中断后可恢复。

### 第五步：初始化 rules + hooks 配置

将以下文件复制到目标项目的 `.codebuddy/` 目录：

**rules/（规则与规范）：**
- `agent-dispatch.md` — Agent 分派规则（主 Agent 只分派不执行）
- `state-machine.md` — 状态机完整定义（含守卫条件、异常回退）
- `verification-gates.md` — 质量门禁规则
- `monitoring.md` — 监控与告警规则
- `memory-system.md` — 三层记忆系统规则

**hooks/（Git 钩子）：**
- `pre-commit` — 提交前检查（lint + format + unit test）
- `commit-msg` — 提交信息验证（WHAT+WHY 格式）
- `pre-push` — 推送前检查
- `post-checkout` — 切换分支后提示
- `install.sh` — Git hooks 安装脚本

**复制方式：**
```
目标项目/.codebuddy/
├── teams/          ← 团队配置（由 Step 2.2 生成）
├── rules/          ← 从 harness/rules/ 复制
├── agents/         ← 从 harness/agents/ 复制
├── hooks/          ← 从 harness/hooks/ 复制
├── evals/          ← 从 harness/evals/ 复制
├── skills/         ← 从 harness/skills/ 复制
├── memory/         ← 创建空目录
├── scripts/        ← 从 harness/scripts/ 复制
└── src/            ← 从 harness/src/ 复制（如存在）
```

安装 Git hooks：
```bash
cd 目标项目/.codebuddy/hooks && bash install.sh
```

### 第六步：等待用户输入

**⚠️ 团队就绪后必须停下来等待用户输入。**

禁止行为：
- ❌ 自行编造需求或功能点
- ❌ 自动推进状态机流转
- ❌ 假设用户要做什么

正确行为：
```
✅ 输出团队就绪信息，等待用户提出需求
❌ 自行开始 "让我来规划一个用户管理系统..."
```

输出格式：
```
🏗️ WebHarness 团队已就绪

团队: harness-team
成员: pm / planner / coder / reviewer / tester / evaluator / deployer
状态: IDEA（等待需求输入）

配置已初始化:
  ✅ teams/    — 团队配置（项目级 .codebuddy/teams/）
  ✅ rules/    — 5 个规则文件
  ✅ hooks/    — 4 个 Git 钩子（已安装）
  ✅ agents/   — 7 个角色定义
  ✅ evals/    — 评估体系

请告诉我你要做什么。
```

---

## 分派规则

**核心原则：主 Agent（Team Lead）只做任务拆解与分派，不做具体执行。**

| ✅ 主 Agent 可以做 | ❌ 主 Agent 禁止做 |
|---|---|
| 任务拆解、角色分配 | 直接写代码 |
| 依赖编排、进度追踪 | 直接运行测试 |
| 质量把关、冲突仲裁 | 亲自部署 |
| 信息查询（仅读取） | 替代其他角色做决策 |

### 分派映射

| 需求类型 | 分派目标 |
|----------|----------|
| 写/改代码 | `coder` |
| 写/跑测试 | `tester` |
| 部署操作 | `deployer` |
| 质量评估 | `evaluator` |
| 方案设计 | `planner` |
| 代码评审 | `reviewer` |
| 发布审批 | `pm` |

---

## 协作模式

| 模式 | 适用场景 | 流程 |
|------|----------|------|
| **流水线** | 功能开发 | Planner→Coder→Reviewer→Deployer→Tester→Evaluator |
| **扇出扇入** | 并行开发 | PM 同时分派给多个 Coder，结果汇聚到 Reviewer |
| **Review 循环** | 修复 Bug | Coder→Reviewer→(BLOCK)→Coder→Reviewer→(PASS)→Deployer |

---

## 注意事项

1. **Review 是强制环节**：CODE 之后必须经过 REVIEW，不可跳过
2. **默认测试环境**：deploy 默认测试环境，`--prod` 需 PM 审批
3. **TDD 驱动**：Coder 先读测试骨架，按 RED→GREEN→REFACTOR 循环
4. **E2E 禁止 mock 后端**：TEST-RUN 的 E2E 必须使用真实后端
5. **评分门禁**：EVAL <60 BLOCK 打回，60-79 WARN 修复重测，≥80 PASS
6. **主 Agent 只分派**：Team Lead 不做具体执行
7. **团队就绪后等待用户**：禁止自行生成需求或自动推进状态机
8. **不覆盖已有文件**：目标目录已存在同名文件时先询问用户
