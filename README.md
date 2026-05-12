# Harness — WebApp 多智能体协作框架

> ⭐ 一个专为 Web 应用设计的多智能体开发框架，支持 TDD、Code Review、自动化部署、质量评估。

## 核心原则

| 原则 | 说明 |
|------|------|
| **主 Agent 只分派，不执行** | Team Lead 负责任务拆解、角色分配、质量把关，不做具体编码/测试/部署 |
| **TDD 驱动开发** | TEST-PLAN（测试骨架）→ CODE（RED→GREEN）→ TEST-RUN（E2E） |
| **测试/生产分离** | `deploy` 默认测环境，`deploy --prod` 需 PM 审批 |
| **Code Review 强制** | 每次 CODE 后必须经过 Reviewer Agent 评审 |

## 项目结构

```
harness/
├── codebuddy.md                # ⭐ Karpathy 4条编码原则
├── install.sh                  # ⭐ 一键安装脚本（部署到任意 CodeBuddy 项目）
├── uninstall.sh                # ⭐ 卸载脚本（安全删除）
│
├── rules/                       # 📐 规则与规范
│   ├── state-machine.md        #    ⭐ 状态机（11状态）
│   ├── agent-dispatch.md       #    ⭐ Agent 分派规则（核心约束）
│   ├── memory-system.md        #    三层记忆系统规则
│   ├── monitoring.md           #    监控与告警规则
│   ├── verification-gates.md   #    质量门禁规则
│   ├── .eslintrc.json          #    ESLint 配置
│   ├── .prettierrc.json        #    Prettier 配置
│   └── tsconfig.json           #    TypeScript 严格模式
│
├── agents/                      # 🤖 Agent 角色定义（7个）
│   ├── pm.md                   #    项目管理者
│   ├── planner.md              #    架构规划师
│   ├── coder.md                #    核心开发者
│   ├── reviewer.md             #    代码评审师
│   ├── tester.md               #    测试专家
│   ├── evaluator.md            #    质量评估师
│   └── deployer.md             #    部署工程师
│
├── skills/                      # 📋 技能包
│   ├── web-harness/            #    ⭐ 核心技能包
│   │   └── SKILL.md            #      主技能入口
│   ├── evals/                  #    评估技能
│   │   └── evaluation.md       #      WebApp 5维度评估体系
│   └── manual/                 #    使用手册技能
│       └── manual.md           #      团队操作指南
│
├── memory/                      # 🧠 记忆系统
│   ├── config.json             #    配置（retention/sync）
│   ├── state.json              #    当前会话状态
│   ├── decisions.log           #    决策审计日志
│   └── README.md
│
├── evals/                       # 📊 评估体系
│   ├── standards.json          #    5 维度评估标准
│   ├── baseline.json           #    基线指标
│   ├── eval-runner.js          #    评估运行器
│   └── README.md
│
├── scripts/                     # 🔧 自动化脚本
│   ├── setup.sh                #    环境初始化
│   ├── health-check.sh         #    健康检查
│   ├── deploy-test.sh          #    测试环境部署
│   ├── deploy-prod.sh          #    生产部署（含备份）
│   ├── rollback.sh             #    版本回滚
│   ├── run-eval.sh             #    运行评估
│   └── README.md
│
├── hooks/                       # 🪝 Git Hooks
│   ├── pre-commit              #    提交前检查（敏感信息/TS/Lint/测试）
│   ├── commit-msg              #    提交信息格式验证
│   ├── pre-push                #    推送前检查（完整测试 + 构建）
│   ├── post-checkout           #    分支切换处理
│   ├── install.sh              #    一键安装脚本
│   └── README.md
│
├── docs/                        # 📚 文档中心
│   ├── specs/
│   │   └── SPEC-TEMPLATE.md    #    ⭐ 功能规格模板（TDD）
│   └── api/
│       └── API-TEMPLATE.yaml   #    OpenAPI 3.0 模板
│
├── tests/                       # 🧪 测试套件
│   └── unit/
│       └── test-skeleton.test.ts
│
├── vitest.config.ts            # Vitest 配置
└── package.json
```

## 状态机（11 状态）：详见 `rules/state-machine.md`

```
IDEA → PLAN → TEST-PLAN → CODE → REVIEW → DEPLOY-TEST → TEST-RUN → EVAL → DEPLOY-PROD → MONITOR → ARCHIVE
```

| 状态 | 说明 | 核心角色 |
|------|------|----------|
| `IDEA` | 需求收集与澄清 | PM + Planner |
| `PLAN` | 技术方案设计 | Planner |
| `TEST-PLAN` | 输出测试用例骨架（TDD） | Planner + Tester |
| `CODE` | TDD 循环实现 | Coder |
| `REVIEW` | 代码审查（强制） | **Reviewer** |
| `DEPLOY-TEST` | 部署测试环境 | Deployer |
| `TEST-RUN` | E2E 测试 + 回归 | Tester |
| `EVAL` | 质量评分 | Evaluator |
| `DEPLOY-PROD` | 生产发布 | Deployer + PM |
| `MONITOR` | 线上监控 | Deployer + PM |
| `ARCHIVE` | 版本归档 | 全员 |

### 状态转换规则

- `IDEA → PLAN`：需求评审通过，AC 定义完成
- `PLAN → TEST-PLAN`：技术方案完成，API 契约定义
- `TEST-PLAN → CODE`：测试用例骨架输出完成
- `CODE → REVIEW`：所有测试 GREEN，Lint 通过
- `REVIEW → DEPLOY-TEST`：Reviewer 通过（6 维度检查）
- `DEPLOY-TEST → TEST-RUN`：Health Check 通过
- `TEST-RUN → EVAL`：E2E 100% 通过
- `EVAL → DEPLOY-PROD`：评分 ≥ 80

## Agent 角色体系

| Agent | 职责 | 在状态机中的角色 |
|-------|------|-----------------|
| `PM` | 需求把控、发布审批 | IDEA 主导、MONITOR/DEPLOY-PROD 审批 |
| `Planner` | 技术方案、任务拆解 | PLAN 主导 |
| `Coder` | 代码实现（TDD） | CODE 主导 |
| `Reviewer` | 代码审查 | REVIEW 主导 |
| `Tester` | 测试计划 + E2E 执行 | TEST-PLAN + TEST-RUN 主导 |
| `Evaluator` | 质量评估 | EVAL 主导 |
| `Deployer` | 部署与环境管理 | DEPLOY-TEST/PROD 主导 |

> **分派规则**：主 Agent（Team Lead）只做任务拆解和分派，不执行具体代码/测试/部署。

## Skills 使用指南

### 技能清单

| 技能 | 路径 | 说明 |
|------|------|------|
| **web-harness** | `skills/web-harness/SKILL.md` | ⭐ 核心入口：生成完整 Harness 框架 |
| **evals** | `skills/evals/evaluation.md` | WebApp 5 维度质量评估体系 |
| **manual** | `skills/manual/manual.md` | 团队操作指南（快速开始/日常流/FAQ） |

### 方式一：在 CodeBuddy 中安装（推荐）

将技能复制到 CodeBuddy 的技能目录，即可通过 `/web-harness` 命令调用：

```bash
# 用户级安装（所有项目可用）
cp -r skills/web-harness ~/.workbuddy/skills/
cp -r skills/evals ~/.workbuddy/skills/
cp -r skills/manual ~/.workbuddy/skills/

# 或使用一键安装脚本
./install.sh --user
```

安装后，在 CodeBuddy 对话中输入：

```
/web-harness
初始化一个 web 项目，tech_stack 是 react + fastapi
```

### 方式二：项目级安装

将技能复制到目标项目的 `.workbuddy/skills/` 目录，仅该项目可用：

```bash
./install.sh /path/to/your/project
```

### 方式三：直接引用（无需安装）

在 CodeBuddy 中打开本仓库作为工作空间，技能会自动被识别。

### 技能触发词

| 触发词 | 激活技能 |
|--------|----------|
| `新建工程` `初始化框架` `生成 harness` | web-harness |
| `webapp 框架` `项目脚手架` `多 agent 协作` | web-harness |
| `build-team` `组建团队` | web-harness |
| `质量评估` `评估体系` `eval` | evals |
| `使用手册` `操作指南` `如何使用` | manual |

### 自定义技能

在 `skills/` 目录下创建新的子目录和 `SKILL.md` 即可扩展：

```
skills/
└── my-custom-skill/
    └── SKILL.md      # 技能定义文件（必须）
```

SKILL.md 格式参考 `skills/web-harness/SKILL.md`，核心字段：

```yaml
---
name: my-custom-skill
description: 技能描述和触发词
agent_created: true        # 标记为 Agent 创建的技能
---
# 技能标题
## 概述 / 何时使用 / 使用方式 / 注意事项
```

## 本地开发

```bash
# 初始化环境
./scripts/setup.sh

# 健康检查
./scripts/health-check.sh

# 测试环境部署
./scripts/deploy-test.sh

# 生产部署
./scripts/deploy-prod.sh v1.0.0

# 回滚
./scripts/rollback.sh backups/v1.0.0

# 运行评估
./scripts/run-eval.sh
```

## Git Hooks 安装

```bash
./hooks/install.sh
```

## 质量门禁

| 维度 | 指标 | 阈值 |
|------|------|------|
| 代码质量 | Lint 通过率 | 100% |
| | TypeScript 类型覆盖 | ≥ 95% |
| | 测试覆盖率 | ≥ 80% |
| 工作流正确性 | 状态转换准确率 | 100% |
| | 守卫规则符合率 | 100% |
| Agent 协作 | 任务委托准确性 | ≥ 90% |
| | 消息送达率 | ≥ 99% |
| 部署质量 | 构建成功率 | 100% |
| | 冒烟测试通过率 | 100% |

## Git 提交规范

```bash
# 格式
<type>(<scope>): <subject>

# 类型
feat    新功能
fix     修复
docs    文档
style   格式
refactor 重构
test    测试
chore   构建/工具

# 示例
feat(core): add agent dispatch rule
fix(ui): resolve button alignment issue
docs: update state machine documentation
```

## 仓库信息

- **地址**：https://github.com/fingermelody/harness.git
- **分支**：main
- **License**：MIT

```bash
git clone https://github.com/fingermelody/harness.git
cd harness
```