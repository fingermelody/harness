# Harness — WebApp 多智能体协作框架

## 概述

本仓库是 **WebHarness 技能框架**的代码载体，包含：

- `skills/web-harness/` — WorkBuddy 技能包（可直接安装到 WorkBuddy）
- `tests/` — 框架自身的 TDD 测试套件
- `docs/` — 框架设计文档

## 项目结构

```
harness/
├── skills/
│   └── web-harness/           # ⭐ 核心技能包
│       ├── SKILL.md          #    主技能定义（触发词 + 使用流程）
│       ├── assets/           #    静态资源
│       └── references/        #    参考文档
│           ├── agents.md     #    6 个 Agent 角色定义
│           ├── state-machine.md  # 状态机工作流（TDD+测试后置）
│           ├── evaluation.md #    WebApp 评估体系
│           ├── verification.md  # 质量门禁（7 层）
│           ├── monitoring.md #    监控机制
│           ├── memory.md     #    三层记忆系统
│           ├── team-engine.md   # build-team 团队引擎
│           └── manual.md     #    使用手册
├── tests/
│   └── unit/
│       └── test-skeleton.test.ts  # TDD 测试骨架
└── docs/                      # 设计文档（可选）
```

## 快速开始

### 安装技能到 WorkBuddy

```bash
# 方式一：从本仓库安装
# 复制 skills/web-harness/ 到 ~/.workbuddy/skills/web-harness/

# 方式二：直接使用本仓库作为工作空间
# 在 WorkBuddy 中打开本目录
```

### 生成新的 Harness 项目

在工作 Buddy 中输入：

```
初始化一个 web 项目，使用 harness 框架，tech_stack 是 react + fastapi
```

将自动生成包含 6 个 Agent 角色、状态机、评估体系、验证机制、监控、记忆系统的完整框架。

### 本地测试

```bash
cd /Users/ping/WorkBuddy/harness
npx vitest run tests/unit/
```

## 核心设计原则（v2）

### TDD 驱动

- **TEST-PLAN**：编码前，Planner + Tester 联合输出测试用例骨架
- **CODE**：Coder 按 RED→GREEN→REFACTOR 循环实现
- **TEST-RUN**：部署到测试环境后执行 E2E（禁止 mock）

### 测试/生产环境分离

| 环境 | 触发方式 | 说明 |
|------|---------|------|
| 测试环境 | `deployer deploy`（默认） | 自动化验证用 |
| 生产环境 | `deployer deploy --prod` | 需 PM 审批 |

### 状态机（8 状态）

```
IDEA → PLAN → TEST-PLAN → CODE → DEPLOY-TEST → TEST-RUN → EVAL → DEPLOY-PROD → MONITOR → ARCHIVE
```

## Git 仓库

- **仓库地址**：https://github.com/fingermelody/harness.git
- **默认分支**：main
- **提交规范**：conventional commits

```bash
git clone https://github.com/fingermelody/harness.git
cd harness
git remote -v  # 确认 remote 正确
```
