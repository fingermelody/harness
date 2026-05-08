# WebHarness 使用手册

> 🏗️ WebApp 多智能体协作框架 — 团队操作指南

---

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
# （在 WorkBuddy 中执行）
/web-harness --project ./my-webapp --stack nextjs

# ② 进入项目目录
cd my-webapp

# ③ 查看生成的核心文件
cat codebuddy.md          # 项目宪法
ls .agents/               # 6 个角色定义
ls docs/                  # 完整文档体系
```

### 1.3 首次配置检查清单

初始化后，请逐项确认：

- [ ] `codebuddy.md` 中的技术栈信息与实际一致
- [ ] `.agents/` 中的角色定义符合团队需求（可增删改）
- [ ] `scripts/setup.sh` 执行成功（环境依赖安装完毕）
- [ ] `.gates.yml` 的门禁规则符合团队标准
- [ ] Git 仓库已初始化且首次 commit 成功
- [ ] CI 流水线已配置（`.github/workflows/`）

### 1.4 你的第一个 Feature

```bash
# 1. 以 PM 身份提出需求
echo "实现用户登录功能" | workbuddy --role pm

# 2. Planner 自动介入，输出方案
# → docs/plan/user-login/architecture.md
# → docs/plan/user-login/tasks.json

# 3. Coder 开始开发
workbuddy --role coder --task "实现登录 API + 登录页面"

# 4. Tester 自动接手测试
workbuddy --tester run-e2e

# 5. Evaluator 评分
workbuddy --evaluator assess

# 6. 达标后 Deployer 发布
workbuddy --deployer release --env staging
```

---

## 2. 项目结构说明

### 2.1 核心文件一览

| 文件/目录 | 用途 | 谁维护 |
|-----------|------|--------|
| `codebuddy.md` | 项目宪法：原则、规范、约定 | 全员共同维护 |
| `.agents/*.md` | 6 个 Agent 角色定义 | PM + Tech Lead |
| `.skills/` | 可复用的技能库（可扩展） | 按需添加 |
| `docs/` | 项目文档（自动生成 + 手写） | 全员 |
| `scripts/` | 自动化脚本（CI/CD + 运维） | DevOps / Coder |
| `tests/` | 测试代码 | Tester 主导 |
| `.gates.yml` | 质量门禁配置 | Evaluator 维护 |

### 2.2 codebuddy.md 是什么？

`codebuddy.md` 是整个框架的**核心宪法**。它定义了：

- **项目定位**：一句话描述这是什么项目
- **技术栈**：前端/后端/数据库/部署
- **编码规范**：命名、文件组织、Git 工作流
- **架构约束**：分层、通信方式、数据流
- **质量标准**：覆盖率基线、性能要求、安全红线

**重要**：任何与 codebuddy.md 约定冲突的代码，在 Code Review 阶段必须被指出。

---

## 3. 日常工作流

### 3.1 开发一个新功能（标准流程）

```
┌─→ 1. PM 录入需求到 Backlog
│
├─→ 2. Planner 分析需求 → 输出方案文档 + 任务拆解
│      ↓ 方案审批
│
├─→ 3. Coder 领取任务 → 编码 + 单元测试
│      ↓ 自测通过
│
├─→ 4. Tester 执行 E2E + 边界测试
│      ↓ 测试通过
│
├─→ 5. Evaluator 运行全套评估 → 出具评分报告
│      ↓ PASS
│
├─→ 6. Deployer 部署到 Staging → Smoke Test
│      ↓ 验证通过
│
└─→ 7. PM 确认发布窗口 → Deployer 上线
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

### 3.3 日常站会（Daily Standup）

每个 Agent 角色汇报格式：

| 角色 | 汇报内容 |
|------|----------|
| PM | 昨天完成 / 今天计划 / 阻塞项 |
| Planner | 方案评审进展 / 技术风险 |
| Coder | 正在开发的 Task / Code Review 状态 |
| Tester | 测试进度 / 发现的 Bug 数量和等级 |
| Evaluator | 最近一次评估结果 / 质量趋势 |
| Deployer | 当前部署状态 / 线上健康度 |

---

## 4. Agent 协作指南

### 4.1 如何发起单 Agent 任务

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

### 4.2 如何发起多 Agent 协作

对于复杂任务，使用 PM 角色**编排多 Agent**：

```
我需要完成一个完整的"用户注册+邮箱验证"功能。
请你以 PM 身份协调：
1. 先让 Planner 出方案
2. 再让 Coder 实现
3. 然后 Tester 测试
4. 最后 Evaluator 评估
```

PM 角色会自动串起整个链路。

### 4.3 自定义 Agent 行为

编辑对应的 `.agents/<role>.md` 文件即可调整该角色的行为：

```bash
# 例：让 Coder 更注重性能
vim .agents/coder.md
# 在技能矩阵中增加：
# - 性能优化 ★★★★☆ - 所有代码需考虑渲染性能
```

---

## 5. 状态机操作

### 5.1 查看当前状态

```bash
# 查看 state log
cat docs/state-log.md | tail -20

# 或让 AI 汇报
当前项目各 Feature 处于什么状态？
```

### 5.2 手动推进状态

正常情况下状态由门禁系统自动推进。如需手动干预：

```bash
# 在 state-log.md 中追加记录
## [2026-05-07T12:00:00Z] MANUAL_TRANSITION
- **from**: TEST
- **to**: EVAL
- **trigger**: 手动推进（原因：XXX）
- **actor**: @ping
- **notes**: XXX
```

### 5.3 异常回退

当需要回退到之前的状态时：

1. 在 `state-log.md` 记录回退原因
2. 通知相关角色（Planner/Coder）
3. 更新任务状态（Issue/PR 重开）

---

## 6. 评估与门禁

### 6.1 触发评估

```bash
# 方式 1：手动触发
./scripts/run-eval.sh

# 方式 2：AI 触发
评估一下 src/features/auth/ 模块的质量

# 方式 3：CI 自动触发（PR / Release 时）
# 已在 .github/workflows/ 中配置
```

### 6.2 解读评估报告

报告位于 `reports/evaluation-[timestamp].md`：

- **总分 ≥ 80 (A)**：✅ 直接进入部署阶段
- **总分 60-79 (B/C)**：⚠️ 需 PM 确认后放行，改进建议记入 Backlog
- **总分 < 60 (F)**：🚫 阻止部署，打回修复

### 6.3 门禁被阻断怎么办

1. 查看 Block 原因（哪个检查项失败）
2. 修复问题
3. 推送 fix commit
4. CI 自动重新运行门禁
5. 通过后继续流程

### 6.4 紧急发布（跳过部分门禁）

仅限生产 P0 故障：

```bash
# 发起 hotfix 流程
./scripts/verify-gate.sh --hotfix --issue INC-123
```

Hotfix 会保留最核心的检查（Lint + Unit Test + Security），跳过非必要项。

---

## 7. 监控与告警

### 7.1 启动健康检查

```bash
# 检查本地 dev 环境
./scripts/health-check.sh dev

# 检查 Staging
./scripts/health-check.sh staging

# 检查生产（含 SSL 证书检查）
./scripts/health-check.sh prod
```

### 7.2 查看监控面板

访问 Grafana Dashboard（URL 见部署配置）查看：
- 请求 RPS / 错误率 / 延迟分布
- 服务器资源使用情况
- 数据库 / Redis 状态
- 最近告警事件

### 7.3 常见监控场景处理

| 场景 | 可能原因 | 处理步骤 |
|------|----------|----------|
| 错误率飙升 | 新版本引入 Bug | 立即回滚 → 定位根因 → 修复 |
| P99 延迟突增 | DB 慢查询 / 缓存穿透 | 检查慢查询日志 → 优化 SQL / 加缓存 |
| 内存持续上涨 | 内存泄漏 | 重启服务 → 用 heap profiler 定位泄漏点 |
| 磁盘空间 > 85% | 日志堆积 / 临时文件 | 清理旧日志 → 设置 log rotation |
| DB 连接池耗尽 | 连接未释放 / 慢查询堆积 | 检查连接超时设置 → 优化慢查询 |

---

## 8. 自定义扩展

### 8.1 添加新的 Agent

```bash
# 1. 创建 agent 定义文件
cat > .agents/security-specialist.md << 'EOF'
# 安全专家 Agent
...（参考 agents.md 格式）...
EOF

# 2. 在 codebuddy.md 中注册
# 3. 更新状态机中的权责矩阵
# 4. 更新协作拓扑图
```

### 8.2 添加新的技能

```bash
mkdir -p .skills/my-skill
cat > .skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: 我的专属技能
---
# My Skill
...（技能工作流）...
EOF
```

### 8.3 添加新的门禁规则

编辑 `.gates.yml`：

```yaml
levels:
  pr:
    checks:
      - name: my-custom-check    # 新增
        tool: custom-script
        severity: block
```

### 8.4 添加新的监控指标

1. 在应用代码中埋点（Prometheus client / Custom metrics）
2. 在 `alerts.yml` 中添加对应告警规则
3. 在 Grafana Dashboard 中添加面板

---

## 9. 常见问题 FAQ

**Q: 这个框架会拖慢开发速度吗？**

A: 初次使用会有学习成本，但一旦建立起来反而**加速**。因为：
- 规范明确减少了沟通成本
- 自动化门禁避免了低级 bug 流入生产
- 标准化的流程让新人快速上手

**Q: 小团队（< 3 人）适合吗？**

A: 适合。Agent 角色可以由一人兼多个角色。关键是**规范先行**——即使一个人也要有 Planner 思维去设计方案、Tester 思维去考虑边界。

**Q: 必须全部 6 个角色都用上吗？**

A: 不必。最小可用集合是 **PM + Coder + Tester**。其他角色按需启用。

**Q: 和现有的 GitHub/GitLab CI/CD 冲突吗？**

A: 不冲突。WebHarness 的门禁脚本生成的是标准的 GitHub Actions / GitLab CI 配置，可以直接复用你现有的 CI 基础设施。

**Q: 支持哪些技术栈？**

A: 框架本身是技术栈无关的。内置模板支持 React/Vue（前端）、FastAPI/Django/Node.js（后端）。其他栈可通过 `--stack custom` 自定义。

**Q: 如何迁移现有项目？**

A: 在已有项目中调用 `/web-harness`，它会：
1. 检测已有文件并询问是否覆盖
2. 只生成缺失的部分
3. 不修改已有的业务代码

**Q: 生成的框架可以商用吗？**

A: 可以。MIT 开源协议，自由使用和修改。

---

*WebHarness v1.0 — 让每个 Web 项目都有世界级的工程实践*
