# WebHarness 使用手册

> 🏗️ WebApp 多智能体协作框架 — 团队操作指南

## 目录

1. [快速开始](#1-快速开始)
2. [项目结构说明](#2-项目结构说明)
3. [日常工作流](#3-日常工作流)
4. [Agent 协作指南](#4-agent-协作指南)
5. [状态机操作](#5-状态机操作)
6. [评估与门禁](#6-评估与门禁)
7. [监控与告警](#7-监控与告警)
8. [自定义扩展](#8-自定义扩展)
9. [常见问题 FAQ](#9-常见问题-faq)

---

## 1. 快速开始

### 1.1 前置条件

- 已安装 Git、Node.js（或 Python，视技术栈而定）
- 有 AI Agent 环境（WorkBuddy / Claude Code / 兼容工具）
- 对项目的目标和技术栈有基本认知

### 1.2 五分钟初始化

```bash
# ① 调用 WebHarness 技能生成框架
/web-harness --project ./my-webapp --stack nextjs

# ② 进入项目目录
cd my-webapp

# ③ 查看生成的核心文件
cat README.md
ls agents/               # 7 个角色定义
ls docs/                  # 完整文档体系
```

### 1.3 首次配置检查清单

初始化后，请逐项确认：

- [ ] `README.md` 中的技术栈信息与实际一致
- [ ] `agents/` 中的角色定义符合团队需求（可增删改）
- [ ] `scripts/setup.sh` 执行成功（环境依赖安装完毕）
- [ ] `evals/standards.json` 的门禁规则符合团队标准
- [ ] Git 仓库已初始化且首次 commit 成功

### 1.4 你的第一个 Feature

```bash
# 1. PM 录入需求
/web-harness init-feature --name "用户登录" --stack react+fastapi

# 2. Planner 自动介入，输出方案
# → docs/specs/feat-xxx/SPEC.md
# → docs/plan/feat-xxx/tasks.json

# 3. Coder 开始开发（TDD 驱动）
# → src/features/auth/
# → tests/e2e/auth.spec.ts

# 4. Reviewer 评审
# → docs/reviews/feat-xxx.md

# 5. Deployer 部署到 Staging
# → scripts/deploy-test.sh

# 6. Tester 执行 E2E
# → scripts/run-eval.sh
```

---

## 2. 项目结构说明

### 2.1 核心目录一览

| 目录 | 用途 | 谁维护 |
|------|------|--------|
| `agents/` | 7 个 Agent 角色定义 | PM + Tech Lead |
| `skills/` | 可复用的技能库 | 按需添加 |
| `commands/` | 可复用的命令模板 | 按需添加 |
| `docs/` | 项目文档（自动生成 + 手写） | 全员 |
| `scripts/` | 自动化脚本（CI/CD + 运维） | DevOps / Coder |
| `tests/` | 测试代码 | Tester 主导 |
| `evals/` | 评估体系和基线 | Evaluator 维护 |
| `memory/` | 三层记忆系统 | 全员 |
| `rules/` | 规则与规范（含 Agent 分派规则） | 全员 |
| `hooks/` | Git 钩子 | DevOps |

---

## 3. 日常工作流

### 3.1 开发一个新功能（标准流程）

```
┌─→ 1. PM 录入需求到 Backlog
│
├─→ 2. Planner 分析需求 → 输出方案文档 + 测试用例骨架
│      ↓ 方案审批
│
├─→ 3. Coder TDD 开发 → RED→GREEN→REFACTOR
│      ↓ 自测通过
│
├─→ 4. Reviewer 代码评审
│      ↓ 通过
│
├─→ 5. Deployer 部署测试环境
│      ↓ Health Check 通过
│
├─→ 6. Tester 执行 E2E + 边界测试
│      ↓ 测试通过
│
├─→ 7. Evaluator 综合评分
│      ↓ PASS (≥80)
│
└─→ 8. PM 确认发布窗口 → Deployer 上线
     ↓
   MONITOR → 回归 IDEA（持续迭代）
```

### 3.2 修复 Bug（快速通道）

P0/P1 Bug 可以跳过部分环节，但**不能跳过测试和评估**：

```
Bug 报告 → Coder 定位修复 → 单元测试验证
         → Tester 回归 → Evaluator 快速评估
         → Deployer Hotfix → 监控观察
```

**注意**：Hotfix 后 24h 内必须补齐所有被跳过的完整流程。

---

## 4. Agent 协作指南

### 4.1 核心原则：主 Agent 只分派，不执行

详见 `rules/agent-dispatch.md`。

### 4.2 如何发起单 Agent 任务

直接指定角色即可：

```
# 让 Planner 设计方案
帮我规划用户权限系统的技术方案

# 让 Coder 写代码
实现 UserAuthService 的 JWT token 刷新逻辑

# 让 Tester 写测试
为购物车结算流程设计 E2E 测试用例

# 让 Evaluator 评一下当前 PR #42 的质量
评估 PR #42 的代码质量

# 让 Deployer 部署
把 v1.3.0 部署到 Staging
```

AI 会根据上下文自动识别应该调用哪个角色的能力。

### 4.3 角色映射表

| 需求类型 | 分派目标 | 判断依据 |
|----------|----------|----------|
| 写/改代码 | `coder` | 涉及 `.ts`, `.js`, `.py` 等源文件变更 |
| 写/跑测试 | `tester` | 涉及测试用例编写、测试执行 |
| 部署操作 | `deployer` | 涉及构建、发布、环境配置 |
| 质量评估 | `evaluator` | 涉及评分、报告生成 |
| 方案设计 | `planner` | 架构选型、技术方案、API 设计 |
| 代码评审 | `reviewer` | Code Review、PR/MR 审核 |
| 项目管理 | `pm` | 进度追踪、优先级、审批 |

---

## 5. 状态机操作

### 5.1 查看当前状态

```bash
# 查看 state log
cat docs/state-log.md | tail -20

# 或让 AI 汇报
当前项目各 Feature 处于什么状态？
```

### 5.2 状态转换规则

详见 `docs/STATE-MACHINE.md`。

---

## 6. 评估与门禁

### 6.1 触发评估

```bash
# 方式 1：运行脚本
./scripts/run-eval.sh

# 方式 2：AI 触发
评估一下 src/features/auth/ 模块的质量
```

### 6.2 解读评估报告

- **总分 ≥ 80 (A)**：✅ 直接进入部署阶段
- **总分 60-79 (B/C)**：⚠️ 需 PM 确认后放行
- **总分 < 60 (F)**：🚫 阻止部署，打回修复

---

## 7. 监控与告警

### 7.1 健康检查

```bash
# 检查本地 dev 环境
./scripts/health-check.sh

# 查看 docs/STATE-MACHINE.md 中的健康检查规范
```

### 7.2 监控指标基线

| 指标 | 好 | 需改进 | 差 |
|------|-----|--------|-----|
| LCP | ≤ 2.5s | 2.5s-4s | > 4s |
| FID | ≤ 100ms | 100-300ms | > 300ms |
| CLS | ≤ 0.1 | 0.1-0.25 | > 0.25 |

---

## 8. 自定义扩展

### 8.1 添加新的 Agent

```bash
# 1. 创建 agent 定义文件
cat > agents/security-specialist.md << 'EOF'
# 安全专家 Agent
...（参考 agents/planner.md 格式）...
EOF

# 2. 在 rules/agent-dispatch.md 中注册
```

---

## 9. 常见问题 FAQ

**Q: 这个框架会拖慢开发速度吗？**

A: 初次使用会有学习成本，但一旦建立起来反而**加速**。因为：
- 规范明确减少了沟通成本
- 自动化门禁避免了低级 bug 流入生产
- 标准化的流程让新人快速上手

**Q: 必须全部 7 个角色都用上吗？**

A: 不必。最小可用集合是 **PM + Coder + Tester**。其他角色按需启用。

**Q: 和现有的 CI/CD 冲突吗？**

A: 不冲突。WebHarness 的脚本生成的是标准的 GitHub Actions 配置，可以直接复用你现有的 CI 基础设施。

---

*WebHarness v3.0 — 让每个 Web 项目都有世界级的工程实践*