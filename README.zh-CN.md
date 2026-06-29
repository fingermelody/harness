# Harness — 精选 AI Coding Skills 集

> **Curated AI coding skills for [CodeBuddy](https://codebuddy.cn) & WorkBuddy** — TDD, code diagnosis, multi-agent workflow, PRD→TAPD sync, and more.
> 一站收录来自 [everything-claude-code](https://github.com/affaan-m/everything-claude-code) 和 [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering) 等优秀社区的 **18 个 AI 工程技能**，开箱即用。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Skills: 18](https://img.shields.io/badge/Skills-18-blue)](https://github.com/fingermelody/harness/tree/main/skills)
[![Sources: 2](https://img.shields.io/badge/Sources-ecc%20%7C%20mattpocock-green)](#-技能来源与致谢)
[![Platforms: CodeBuddy%20%7C%20WorkBuddy](https://img.shields.io/badge/Platforms-CodeBuddy%20%7C%20WorkBuddy-orange)](https://codebuddy.cn)
[![GitHub stars](https://img.shields.io/github/stars/fingermelody/harness?style=social)](https://github.com/fingermelody/harness)

[English](README.md) · [简体中文](README.zh-CN.md)

---

## ✨ 这是什么

一个**精选 AI Coding Skills 仓库**——把社区里最实用的 AI 工程技能（TDD、问题诊断、需求转换、多 Agent 协作、TAPD 同步…）整合进一套可一键安装的体系。

- ✅ **18 个工程类技能**（编码、TDD、问题诊断、PRD、Issues、部署、评估…）
- ✅ **3 个安装方式**（CodeBuddy 项目级、用户级、WorkBuddy 全局）
- ✅ **2 个权威来源**（everything-claude-code、mattpocock）
- ✅ **0 锁依赖**（纯技能文件，可独立安装使用）

---

## 🌟 明星技能（Featured Skills）

### 1. `tdd-workflow` — TDD 工作流（来自 everything-claude-code）

> **Test-driven development with red-green-refactor loop. 80%+ coverage enforced.**

让 AI 严格遵循 **RED → GREEN → REFACTOR** 三色循环开发功能或修复 Bug：先写失败的测试 → 写最小实现让测试通过 → 重构。强制 80%+ 测试覆盖率，单元/集成/E2E 全覆盖。

**核心特性**

| 阶段 | 任务 | 产出 |
|------|------|------|
| **RED** | 编写失败测试 | 红色测试用例 |
| **GREEN** | 写最小实现 | 绿色测试通过 |
| **REFACTOR** | 清理代码 | 保持绿色 + 提升质量 |
| **VERIFY** | 覆盖率检查 | ≥ 80% 报告 |

**适用场景**：实现新功能、修复 Bug、重构、API 设计、组件开发

```bash
# 在 CodeBuddy / WorkBuddy 中直接调用
/tdd-workflow
帮我用 TDD 方式实现一个用户注册接口
```

---

### 2. `diagnose` — 问题诊断（来自 mattpocock/skills）

> **Disciplined diagnosis loop for hard bugs and performance regressions.**

专门解决**难调问题**和**性能回退**：复现 → 最小化 → 假设 → 验证 → 修复 → 回归测试。五步诊断循环，不靠猜，靠证据。

**诊断流程**

```
Reproduce → Minimise → Hypothesise → Instrument → Fix → Regression Test
   复现        最小化         假设          插桩        修复      回归测试
```

**适用场景**：线上 Bug、性能回退、内存泄漏、并发问题、疑难杂症

```bash
/diagnose
线上偶发 500 错误，错误率 0.5%，集中在下午 3-4 点
```

---

### 3. `to-prd` — 对话转 PRD 并自动同步 TAPD（harness 增强版）

> **把聊天内容转成结构化 PRD，然后一键推送到 TAPD。**

三阶段流程：分析对话提取意图 → 生成结构化 PRD（背景、目标、用户故事、验收标准、实现计划）→ 调用 TAPD API 创建父需求、为每个用户故事创建子需求、并把完整文档保存为 Wiki 页面。

**三阶段流程**

| 阶段 | 任务 | 产出 |
|------|------|------|
| **Analyze** | 提取对话意图 | 目标 + 用户故事 |
| **Generate** | 生成 PRD 文档 | Markdown PRD |
| **Sync** | `stories_create` + `wikis_create` | 落地的 TAPD 需求项 |

**适用场景**：写需求文档、交付给工程团队、同步到 TAPD、与干系人对齐规格

```bash
/to-prd
把本周和 PM 的讨论转成 PRD，并推到 TAPD
```

---

### 4. `to-issues` — PRD 拆解为可独立领取的 Issue（来自 mattpocock/skills）

> **把 PRD 或规格拆成纵向切片的 issue，每个开发者拎起来就能开干。**

采用 **tracer-bullet（曳光弹）** 模式：每个 issue 自带足够上下文（文件路径、测试用例、预期行为），开发者领取后无需额外会议就能直接上手交付。

**适用场景**：PRD 完成后做 Sprint 规划、跨团队分发任务、给新贡献者铺路

```bash
/to-issues
把这个 PRD 拆成可独立领取的 issue
```

---

## 📦 完整技能清单（18 个）

| 技能 | 来源 | 触发词 | 说明 |
|------|------|--------|------|
| **tdd-workflow** ⭐ | ecc | `TDD` `测试驱动` | RED→GREEN→REFACTOR，覆盖率 80%+ |
| **diagnose** ⭐ | mattpocock | `问题诊断` `debug` | 五步诊断循环 |
| **to-prd** ⭐ | harness | `写 PRD` | 对话→PRD，自动同步 TAPD |
| **to-issues** ⭐ | mattpocock | `拆 Issue` | PRD→可独立领取的 Issue |
| **eval-harness** | ecc | `质量评估` `eval` | EDD 评估框架（pass@k 指标） |
| **tdd-matt** | mattpocock | `TDD matt` | mattpocock 风格 TDD |
| **triage** | mattpocock | `任务分诊` | Issue/需求分诊状态机 |
| **prototype** | mattpocock | `原型设计` | 一次性原型验证设计 |
| **zoom-out** | mattpocock | `全局审查` | 全局视角审视代码库 |
| **grill-with-docs** | mattpocock | `文档深挖` | 挑战方案对抗文档 |
| **improve-codebase-architecture** | mattpocock | `架构改进` | 深化代码库架构 |
| **web-harness** | harness | `webapp 框架` `多 agent` | ⭐ 核心入口：生成完整 Harness 框架 |
| **mini-harness** | harness | `mini-harness` | 轻量单文件多 Agent 协作 |
| **basic-code-workflow** | harness | `编码流程` | planner→test→coder→reviewer |
| **deploy-pro** | harness | `生产发布` `部署生产` | 预检→合并→构建→部署→回滚 |
| **deploy-test-workflow** | harness | `测试部署` | deployer→tester |
| **setup-engineering-skills** | harness | `安装工程技能` | 批量安装工程技能 |
| **manual** | harness | `使用手册` `manual` | ⭐ 团队操作指南入口 |

---

## 🚀 一键安装

### 方式 1：WorkBuddy 全局（最快，30 秒上手）

```bash
git clone https://github.com/fingermelody/harness.git
cd harness
./install.sh --workbuddy
```

✅ 18 个技能立刻在 WorkBuddy 任何对话中可用

### 方式 2：CodeBuddy 项目级（推荐用于团队）

```bash
./install.sh /path/to/your/project
# 技能安装到 /path/to/your/project/.codebuddy/skills/
```

### 方式 3：CodeBuddy 用户级

```bash
./install.sh --user
# 技能安装到 ~/.codebuddy/skills/
```

---

## 🎯 何时用哪个技能（决策树）

```
想做什么？
│
├─ 实现新功能
│   ├─ 严格 TDD → /tdd-workflow 或 /tdd-matt
│   └─ 一般编码 → /basic-code-workflow
│
├─ 修复 Bug
│   ├─ 难调问题 → /diagnose
│   └─ 简单 Bug → /tdd-workflow
│
├─ 写需求文档
│   └─ /to-prd（自动同步 TAPD）
│
├─ 拆解任务为 Issue
│   └─ /to-issues（独立可领取的 Issue）
│
├─ 代码质量
│   ├─ 整体评估 → /eval-harness
│   └─ 架构改进 → /improve-codebase-architecture
│
├─ 部署
│   ├─ 测试环境 → /deploy-test-workflow
│   └─ 生产环境 → /deploy-pro
│
└─ 启动多 Agent 协作
    ├─ 轻量单文件 → /mini-harness
    └─ 完整框架 → /web-harness
```

---

## 📚 技能来源与致谢

本仓库的技能来自两个优秀社区：

| 来源 | 仓库 | 贡献技能数 |
|------|------|-----------|
| **everything-claude-code** | [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) | 2（tdd-workflow, eval-harness） |
| **mattpocock/skills** | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering) | 10（diagnose, tdd-matt, to-prd, to-issues, triage, prototype, zoom-out, grill-with-docs, improve-codebase-architecture, setup-engineering-skills） |
| **harness 原创** | 本仓库 | 6（web-harness, mini-harness, basic-code-workflow, deploy-pro, deploy-test-workflow, manual） |

> 💡 技能文件已根据 CodeBuddy 生态适配（"claude" → "codebuddy"），保持原技能逻辑不变。

---

## 🔗 相关资源

- 📖 [完整使用手册](skills/manual/SKILL.md)
- 🏗️ [Harness 框架设计](rules/state-machine.md)（11 状态机 + 7 Agent 角色）
- 🎯 [CodeBuddy 编码原则](codebuddy.md)（Karpathy 4 规则）
- 🛠️ [技能开发模板](skills/web-harness/SKILL.md)

---

## 📊 仓库信息

- **地址**：https://github.com/fingermelody/harness
- **License**：MIT
- **维护**：active，欢迎 PR
- **标签**：`ai-skills` `codebuddy` `workbuddy` `tdd` `diagnose` `multi-agent` `harness` `tapd` `prd` `issues`

---

## 🌟 Star History

如果这个仓库对你有帮助，欢迎 ⭐ Star！你的支持是我们持续整合更多优秀技能的动力。

[![Star History Chart](https://api.star-history.com/svg?repos=fingermelody/harness&type=Date)](https://star-history.com/#fingermelody/harness&Date)

```bash
git clone https://github.com/fingermelody/harness.git
cd harness
./install.sh --workbuddy   # 30 秒上手所有技能
```
