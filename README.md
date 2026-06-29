# Harness — Curated AI Coding Skills Collection

> **Hand-picked AI coding skills for [CodeBuddy](https://codebuddy.cn) & WorkBuddy** — TDD, bug diagnosis, multi-agent workflow, PRD → TAPD sync, and more.
> A single repository of **18 production-ready engineering skills** aggregated from [everything-claude-code](https://github.com/affaan-m/everything-claude-code) and [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering). One command installs them all.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Skills: 18](https://img.shields.io/badge/Skills-18-blue)](https://github.com/fingermelody/harness/tree/main/skills)
[![Sources: 2](https://img.shields.io/badge/Sources-ecc%20%7C%20mattpocock-green)](#-credits--sources)
[![Platforms: CodeBuddy%20%7C%20WorkBuddy](https://img.shields.io/badge/Platforms-CodeBuddy%20%7C%20WorkBuddy-orange)](https://codebuddy.cn)
[![GitHub stars](https://img.shields.io/github/stars/fingermelody/harness?style=social)](https://github.com/fingermelody/harness)

[English](README.md) · [简体中文](README.zh-CN.md)

---

## ✨ What is this?

A **curated AI Coding Skills repository** — bringing the most useful AI engineering skills (TDD, bug diagnosis, requirement conversion, multi-agent collaboration, TAPD sync…) into a single one-command installable package.

- ✅ **18 engineering skills** (coding, TDD, diagnosis, PRD, issues, deployment, evaluation…)
- ✅ **3 install modes** (CodeBuddy project, CodeBuddy user, WorkBuddy global)
- ✅ **2 trusted sources** (everything-claude-code, mattpocock/skills)
- ✅ **0 lock-in** (plain skill files, each installable independently)

---

## 🌟 Featured Skills

### 1. `tdd-workflow` — Test-Driven Development (from everything-claude-code)

> **Test-driven development with red-green-refactor loop. 80%+ coverage enforced.**

Forces AI to follow the **RED → GREEN → REFACTOR** cycle when building features or fixing bugs: write a failing test first, write the minimum code to pass it, then refactor. Enforces 80%+ test coverage across unit, integration, and E2E layers.

**Core Phases**

| Phase | Task | Output |
|-------|------|--------|
| **RED** | Write a failing test | Red test case |
| **GREEN** | Write the minimum implementation | Green test passes |
| **REFACTOR** | Clean up the code | Stay green, raise quality |
| **VERIFY** | Coverage check | ≥ 80% report |

**When to use**: implement new features, fix bugs, refactor, design APIs, build components

```bash
# Invoke directly in CodeBuddy / WorkBuddy
/tdd-workflow
Implement a user registration API using TDD
```

---

### 2. `diagnose` — Hard-Bug Diagnosis (from mattpocock/skills)

> **Disciplined diagnosis loop for hard bugs and performance regressions.**

Built for **gnarly bugs** and **performance regressions**: Reproduce → Minimise → Hypothesise → Instrument → Fix → Regression Test. A five-step evidence-based loop — never guess, always measure.

**Diagnosis Flow**

```
Reproduce → Minimise → Hypothesise → Instrument → Fix → Regression Test
```

**When to use**: production bugs, performance regressions, memory leaks, concurrency issues, mystery errors

```bash
/diagnose
Intermittent 500 errors in production, error rate 0.5%, peaking between 3-4pm
```

---

### 3. `to-prd` — Conversation → PRD with TAPD Sync (harness-enhanced)

> **Turn a chat into a structured PRD, then push it directly to TAPD.**

Three-phase flow: analyze the conversation to extract intent, generate a structured PRD (background, goals, user stories, acceptance criteria, implementation plan), then call TAPD's API to create a parent story, child stories for each user story, and a Wiki page with the full document.

**Three-Phase Flow**

| Phase | Task | Output |
|-------|------|--------|
| **Analyze** | Extract intent from conversation | Goals + user stories |
| **Generate** | Build the PRD document | Markdown PRD |
| **Sync** | `stories_create` + `wikis_create` | Live TAPD items |

**When to use**: writing requirement documents, handoff to engineering, syncing to TAPD, sharing specs with stakeholders

```bash
/to-prd
Turn this week's chat with the PM into a PRD and push it to TAPD
```

---

### 4. `to-issues` — PRD → Independently-Grabbable Issues (from mattpocock/skills)

> **Break a PRD or spec into vertical-slice issues each developer can pick up cold.**

Uses the **tracer-bullet** pattern: each issue contains enough context (file paths, test cases, expected behavior) that a developer can claim it, start work, and ship — no extra meetings required.

**When to use**: PRD is ready, sprint planning, distributing work across a team, creating issues for new contributors

```bash
/to-issues
Break this PRD into independently-grabbable issues
```

---

## 📦 Full Skill Catalog (18)

| Skill | Source | Triggers | Description |
|-------|--------|----------|-------------|
| **tdd-workflow** ⭐ | ecc | `TDD` `test-driven` | RED→GREEN→REFACTOR, 80%+ coverage |
| **diagnose** ⭐ | mattpocock | `diagnose` `debug` | Five-step evidence-based diagnosis loop |
| **to-prd** ⭐ | harness | `write PRD` | Conversation → PRD, auto-sync to TAPD |
| **to-issues** ⭐ | mattpocock | `break down issues` | PRD → independently-grabbable issues |
| **eval-harness** | ecc | `evaluation` `eval` | EDD framework with pass@k metrics |
| **tdd-matt** | mattpocock | `TDD matt` | mattpocock-style TDD |
| **triage** | mattpocock | `triage` | State-machine driven issue triage |
| **prototype** | mattpocock | `prototype` | Throwaway prototype for design validation |
| **zoom-out** | mattpocock | `zoom out` | Whole-codebase perspective review |
| **grill-with-docs** | mattpocock | `grill with docs` | Challenge your plan against the docs |
| **improve-codebase-architecture** | mattpocock | `improve architecture` | Deepen codebase architecture |
| **web-harness** | harness | `webapp framework` `multi-agent` | ⭐ Core entry: full Harness framework |
| **mini-harness** | harness | `mini-harness` | Lightweight single-file multi-agent team |
| **basic-code-workflow** | harness | `coding workflow` | planner → test → coder → reviewer |
| **deploy-pro** | harness | `prod release` `deploy prod` | preflight → merge → build → deploy → rollback |
| **deploy-test-workflow** | harness | `test deploy` | deployer → tester |
| **setup-engineering-skills** | harness | `install engineering skills` | Batch install engineering skills |
| **manual** | harness | `manual` `user guide` | ⭐ Team operations manual entry point |

---

## 🚀 One-Command Install

### Option 1: WorkBuddy Global (fastest, 30 seconds)

```bash
git clone https://github.com/fingermelody/harness.git
cd harness
./install.sh --workbuddy
```

✅ All 18 skills are immediately available in any WorkBuddy conversation.

### Option 2: CodeBuddy Project-Level (recommended for teams)

```bash
./install.sh /path/to/your/project
# Skills install to /path/to/your/project/.codebuddy/skills/
```

### Option 3: CodeBuddy User-Level (global)

```bash
./install.sh --user
# Skills install to ~/.codebuddy/skills/
```

---

## 🎯 Which Skill Should I Use? (Decision Tree)

```
What do you want to do?
│
├─ Implement a new feature
│   ├─ Strict TDD → /tdd-workflow or /tdd-matt
│   └─ Standard coding → /basic-code-workflow
│
├─ Fix a bug
│   ├─ Hard-to-diagnose bug → /diagnose
│   └─ Simple bug → /tdd-workflow
│
├─ Write a requirement document
│   └─ /to-prd (auto-syncs to TAPD)
│
├─ Break down a task into issues
│   └─ /to-issues (independently-grabbable issues)
│
├─ Improve code quality
│   ├─ Overall evaluation → /eval-harness
│   └─ Architecture → /improve-codebase-architecture
│
├─ Deploy
│   ├─ Test environment → /deploy-test-workflow
│   └─ Production → /deploy-pro
│
└─ Start multi-agent collaboration
    ├─ Lightweight single-file → /mini-harness
    └─ Full framework → /web-harness
```

---

## 📚 Credits & Sources

This repository aggregates skills from two outstanding open-source projects:

| Source | Repository | Skills Contributed |
|--------|------------|--------------------|
| **everything-claude-code** | [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) | 2 (tdd-workflow, eval-harness) |
| **mattpocock/skills** | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/engineering) | 10 (diagnose, tdd-matt, to-prd, to-issues, triage, prototype, zoom-out, grill-with-docs, improve-codebase-architecture, setup-engineering-skills) |
| **Harness Original** | this repository | 6 (web-harness, mini-harness, basic-code-workflow, deploy-pro, deploy-test-workflow, manual) |

> 💡 All imported skills have been adapted to the CodeBuddy ecosystem (with "claude" → "codebuddy" replacements) while preserving the original logic.

---

## 🔗 Related Resources

- 📖 [Complete User Manual](skills/manual/SKILL.md)
- 🏗️ [Harness Framework Design](rules/state-machine.md) (11-state machine + 7 agent roles)
- 🎯 [CodeBuddy Coding Principles](codebuddy.md) (Karpathy's 4 Rules)
- 🛠️ [Skill Development Template](skills/web-harness/SKILL.md)

---

## 📊 Repository Info

- **URL**: https://github.com/fingermelody/harness
- **License**: MIT
- **Status**: actively maintained, PRs welcome
- **Topics**: `ai-skills` `codebuddy` `workbuddy` `tdd` `diagnose` `multi-agent` `harness` `tapd` `prd` `issues`

---

## 🌟 Star History

If this repository helps you, please ⭐ Star it! Your support is what keeps us integrating more great skills.

[![Star History Chart](https://api.star-history.com/svg?repos=fingermelody/harness&type=Date)](https://star-history.com/#fingermelody/harness&Date)

```bash
git clone https://github.com/fingermelody/harness.git
cd harness
./install.sh --workbuddy   # Get all 18 skills in 30 seconds
```
