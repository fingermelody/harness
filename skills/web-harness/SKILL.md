---
name: web-harness
description: >
  WebApp 项目 Harness 框架生成器。当用户需要为 Web 应用项目初始化完整的多智能体协作框架时使用，
  包括：项目文档结构(codebuddy.md/skills/docs/scripts/tests)、6个核心角色定义(planner/coder/evaluator/deployer/tester/pm)、
  状态机工作流(TDD驱动+测试后置)、WebApp 专项评估能力、验证机制、监控机制、三层记忆系统(会话/项目/经验)、
  build-team 团队引擎(启动/恢复/重启多Agent协作)、测试/生产环境分离。
  触发词：新建工程、初始化框架、生成 harness、webapp 框架、项目脚手架、多 agent 协作框架、build-team。
agent_created: true
---

# Web-Harness: WebApp 多智能体协作框架

## 概述

本技能为 Web 应用项目快速生成一套**生产级的 Harness 框架**。灵感来源于 OpenHarness 的模块化架构和 Everything Claude Code 的多智能体协作体系，专为 WebApp 场景定制。

**核心理念：** 任何新工程不应从零开始——框架即规范，结构即治理。

**v2 核心原则：TDD 驱动 + 测试后置**
- 测试计划在 CODE 之前完成（TEST-PLAN 阶段）
- 实际测试执行在部署到测试环境之后（TEST-RUN 阶段）
- 默认部署到测试环境，显式命令才部署到生产环境

## 何时使用

- 用户说「新建一个 Web 项目」「初始化工程」「生成 harness 框架」
- 用户说「帮我搭一个多 agent 协作的 WebApp 项目骨架」
- 需要在已有项目中补充 Harness 基础设施（agent 定义、状态机、评估/验证/监控）
- 团队希望标准化新工程的启动流程

## 使用方式

### 第一步：确认目标路径和项目信息

向用户确认以下信息（有默认值时可合理推断）：

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `project_path` | 目标项目根目录 | 当前工作目录 |
| `project_name` | 项目名称 | 目录名 |
| `tech_stack` | 技术栈 (如 react/vue/fastapi/django) | 需询问 |
| `agents` | 需要的 agent 角色 | 全部 6 个 |

### 第二步：执行 `generate` 工作流

调用 **generate-harness** 主工作流，按以下顺序生成：

```
1. confirm-context           → 确认 tech_stack + TDD 策略 + 环境配置
2. generate-structure        → 目录结构 + codebuddy.md
3. generate-agents           → 6 个 agent 角色定义
4. generate-state-machine    → 状态机与转换规则（含 TEST-PLAN/DEPLOY-TEST/DEPLOY-PROD）
5. generate-evaluation       → WebApp 评估体系
6. generate-verification     → 验证机制（质量门禁 + 测试/生产环境分离）
7. generate-monitoring       → 监控机制（健康检查）
8. generate-memory           → 三层记忆系统（会话/项目/经验）
9. generate-team-engine      → build-team 团队引擎（编排/恢复/重启）
10. generate-manual          → 使用手册
11. git-init                 → 初始化 Git 仓库（可选）
```

**TDD 策略确认（第 1 步必做）：**
- 询问用户测试框架选择（Vitest / Jest / pytest / Go test 等）
- 确认单元测试覆盖率目标（默认 80%）
- 确认 E2E 测试工具（Playwright / Cypress / Detox）
- 默认测试后置：TEST-PLAN（计划）在 CODE 前，TEST-RUN（执行）在 DEPLOY-TEST 后

### 第三步：输出交付物

将生成的框架通过 `deliver_attachments` 交付给用户，并用 `preview_url` 展示使用手册（HTML）。

---

## 生成的框架结构

执行后，目标目录将包含：

```
<project-root>/
├── codebuddy.md                  # 🔑 核心原则 & 项目宪法
├── .agents/                      # 🤖 Agent 角色定义
│   ├── planner.md                #    架构规划师
│   ├── coder.md                  #    核心开发者
│   ├── evaluator.md              #    质量评估师
│   ├── deployer.md               #    部署工程师
│   ├── tester.md                 #    测试专家
│   └── pm.md                     #    项目管理者
├── .memory/                      # 🧠 三层记忆系统 (新增!)
│   ├── config.json               #    动态配置记忆 (L2)
│   ├── decisions.log             #    决策日志 (L2, append-only)
│   ├── tech-debt.json            #    技术债登记册 (L2)
│   ├── iteration-learnings.md    #    迭代经验沉淀 (L2)
│   ├── agent-performance.json    #    Agent 历史表现 (L2)
│   └── sessions/                 #    会话记忆 (L1)
│       ├── active.json           #      当前活跃会话状态
│       ├── [session-id]/         #      会话快照与检查点
│       └── archive/              #      已归档会话
├── .skills/                      # 📚 可复用技能库
│   ├── webapp-eval/              #    WebApp 评估技能
│   ├── verification-gate/         #    质量门禁技能
│   ├── health-check/              #    健康监控技能
│   ├── deploy-test/               #    测试环境部署技能（新增）
│   ├── deploy-prod/               #    生产环境发布技能（新增）
│   └── build-team/               #    团队引擎技能
├── docs/                         # 📖 项目文档
│   ├── README.md                 #    项目概览（自动生成）
│   ├── STATE-MACHINE.md          #    状态机说明
│   ├── EVALUATION-CRITERIA.md    #    评估标准
│   ├── VERIFICATION-GATES.md     #    验证门禁规则
│   └── MONITORING.md             #    监控方案
├── scripts/                      # ⚙️ 自动化脚本
│   ├── setup.sh                  #    环境初始化
│   ├── health-check.sh           #    健康检查
│   ├── run-eval.sh               #    执行评估
│   └── verify-gate.sh            #    门禁检查
├── tests/                        # 🧪 测试基础设施
│   ├── conftest.py               #    pytest 配置
│   ├── e2e/                      #    E2E 测试占位
│   └── unit/                     #    单元测试占位
└── .github/                      # 🔄 CI/CD（可选）
    └── workflows/
        └── ci.yml                #    CI 流水线模板
```

---

## 详细设计参考

以下各模块的具体内容定义在对应的 reference 文件中。生成时必须读取这些参考文件并填充到目标项目中。

### Agent 角色体系

参见 [`references/agents.md`](references/agents.md)

包含 6 个角色的：
- 身份定位与职责边界
- 核心技能清单（每个角色 5-8 项）
- 输入/输出契约
- 协作关系图
- Prompt 模板

### 状态机工作流

参见 [`references/state-machine.md`](references/state-machine.md)

包含：
- 完整的状态定义（**IDEA → PLAN → TEST-PLAN → CODE → DEPLOY-TEST → TEST-RUN → EVAL → DEPLOY-PROD → MONITOR**）
- **TEST-PLAN**：测试用例骨架输出（Coder + Tester 联合输出）
- **DEPLOY-TEST**：默认部署到测试环境
- **TEST-RUN**：E2E 测试执行（部署到测试环境后）
- **DEPLOY-PROD**：显式部署到生产环境
- 状态转换条件与守卫规则
- 角色在各状态下的权责
- 异常回退策略
- Mermaid 图定义
- **环境配置规范**（test/prod 双环境）

### WebApp 评估能力

参见 [`references/evaluation.md`](references/evaluation.md)

针对 Web 应用的多维评估体系：
- **功能正确性**：用户故事覆盖、API 契约验证
- **UI/UX 质量**：响应式布局、可访问性(a11y)、交互流畅度
- **性能指标**：LCP/FID/CLS/Core Web Vitals、包体积、 hydration
- **安全性**：XSS/CSRF/CORS/认证鉴权
- **代码质量**：复杂度、覆盖率、技术债
- **评分模型**：0-100 分制 + 等级判定

### 验证机制

参见 [`references/verification.md`](references/verification.md)

多层质量门禁：
- **Commit 级**：lint + format + unit test（TDD GREEN 验证）
- **TEST-PLAN 级**：测试用例骨架评审
- **DEPLOY-TEST 级**：测试环境 Health Check + Smoke Test
- **TEST-RUN 级**：全量 E2E + 安全扫描 + review
- **DEPLOY-PROD 级**：生产发布门禁（灰度/回滚策略 + PM 审批）
- **门禁规则引擎**：PASS/WARN/BLOCK 判定逻辑
- **环境分离**：测试环境（默认）+ 生产环境（显式触发）

### 监控机制

参见 [`references/monitoring.md`](references/monitoring.md)

全方位运行监控：
- **应用层**：health endpoint、error tracking、latency p99
- **基础设施层**：CPU/内存/磁盘/网络
- **业务层**：DAU/转化率/错误率
- **告警规则**：分级告警（info/warn/critical）
- **Dashboard 模板**：关键指标面板

### 使用手册

参见 [`references/manual.md`](references/manual.md)

面向团队成员的操作指南：
- 快速启动（5 分钟上手）
- 日常工作流（开发/提测/发布/排查问题）
- Agent 协作模式（如何发起多 agent 任务）
- 自定义扩展（添加新 agent/新技能/新门禁）
- 故障排查 FAQ

### 记忆系统

参见 [`references/memory.md`](references/memory.md)

三层跨会话记忆架构：
- **L1 会话记忆**：实时任务快照、checkpoint、中断恢复状态（`.memory/sessions/`）
- **L2 项目记忆**：配置、决策日志、技术债、Agent 表现（`.memory/*.json`）
- **L3 经验记忆**：跨项目通用经验、反模式清单、选型经验（`~/.webharness/MEMORY.md`）

支持：自动保存 / 会话恢复 / 原子写入 / 敏感信息过滤

### 团队引擎 (build-team)

参见 [`references/team-engine.md`](references/team-engine.md)

多 Agent 编排核心能力：
- `build-team start` — 组建 6 人团队，启动 Feature 开发
- `build-team status` — 查看团队健康度与各 Agent 状态
- `build-team restart` — 从 checkpoint 恢复卡住的任务
- `build-team pause/resume` — 优雅暂停与恢复
- `build-team stop` — 停止团队并归档
- 支持 3 种协作模式：流水线 / 扇出扇入 / Review 循环
- 内置事件总线（Event Bus）解耦 Agent 通信

---

## 技术栈感知

生成框架时会根据 `tech_stack` 自动调整：

| 技术栈 | codebuddy.md 补充 | scripts 调整 | 测试配置 |
|--------|-------------------|-------------|---------|
| React/Next.js | React 最佳实践、Hooks 规范 | eslint+prettier、vitest | Playwright E2E |
| Vue/Nuxt.js | Composition API 规范、Pinia | eslint+prettier、vitest | Playwright E2E |
| FastAPI | async/await 规范、Pydantic | pytest、ruff | pytest + requests |
| Django | MTV 分层、DRF 规范 | pytest-black、django-silk | pytest + Selenium |
| 全栈(Next.js+FastAPI) | 前后端分离契约 | 双语 lint/test | 前后端联调 E2E |

**环境配置**（每个 tech_stack 都必须包含）：
- 测试环境：默认部署目标（`.env.test` / `.env.staging`）
- 生产环境：显式部署（`.env.production` / `.env.prod`）
- 回滚脚本：自动生成 `scripts/rollback.sh`

## 注意事项

1. **不覆盖已有文件**：如果目标目录已存在同名文件，先询问用户再决定是否覆盖
2. **Git 安全**：仅在空目录或用户明确授权时执行 `git init`
3. **技能是起点不是终点**：生成的框架是团队约定的基准线，应在迭代中持续完善
4. **保持幂等性**：重复执行同一命令不应产生副作用
