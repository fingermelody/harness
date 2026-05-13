---
name: basic-code-workflow
description: >
  基础编程任务工作流编排器。按顺序编排 planner → test-creator → coder → reviewer 四个阶段，
  依次执行任务规划、测试用例编写、TDD 编程、代码评审。
  当用户提出编程任务时默认使用此技能。触发词：实现功能、写代码、开发、编程、fix bug、
  add feature、implement、build、create a function、开发一个、实现一个、写一个。
agent_created: true
---

# Basic-Code-Workflow: 编程任务顺序编排

## 概述

将一次编程任务拆解为 4 个顺序阶段，依次执行，前一阶段输出作为后一阶段输入：

```
planner → test-creator → coder → reviewer
任务规划   测试用例编写    TDD编程   代码评审
```

## 何时使用

- 用户提出任何编程任务时**默认使用**
- 需求明确，不需要多 Agent 团队协作，单线程顺序执行即可
- 用户说「实现 X」「写一个 Y」「开发 Z 功能」「修复 W Bug」

**不使用此技能的场景：**
- 纯信息查询（不涉及代码变更）
- 已有完整团队在运行（使用 web-harness 代替）
- 需要并行开发多个独立功能（使用 web-harness 的扇出模式）

---

## 执行流程

### 前置：确认需求

收到编程任务后，先快速确认：

1. **目标**：要实现什么功能 / 修复什么 Bug？
2. **范围**：涉及哪些文件 / 模块？
3. **约束**：技术栈、性能要求、兼容性？

如果用户描述已足够清晰，直接进入 Step 1；如有歧义，先提问澄清（≤3 轮）。

---

### Step 1: Planner — 任务规划

**目标**：输出技术方案和任务拆解。

**执行方式**：使用 Agent 工具 spawn planner agent。

**Planner Prompt 模板：**

```
你是架构规划师，为以下编程任务制定技术方案。

任务：{用户需求}
技术栈：{tech_stack}
现有代码：{相关文件路径}

输出格式：
1. 需求分析：确认功能边界和验收标准
2. 技术方案：实现思路（如有多种方案，对比后推荐一种）
3. 任务拆解：拆为 Story + Task（含优先级 P0/P1/P2）
4. 文件变更清单：需要新建/修改的文件列表
5. 风险点：潜在问题及缓解策略
```

**Planner 输出**：技术方案文档 → 传给 Step 2

---

### Step 2: Test-Creator — 测试用例编写

**目标**：根据技术方案输出测试用例骨架（TDD 基础）。

**执行方式**：使用 Agent 工具 spawn test-creator agent。

**Test-Creator Prompt 模板：**

```
你是测试工程师，根据技术方案编写测试用例骨架。

技术方案：
{Step 1 的输出}

输出要求：
1. 为每个 Task 编写 BDD Scenario（Given-When-Then 格式）
2. 创建测试文件骨架：
   - 文件路径遵循项目测试目录规范
   - 每个 Scenario 一个 test case
   - 测试体为 TODO 占位：expect(true).toBe(false) 或 assert False
   - 注释标注期望行为
3. 定义测试数据 fixture / mock 策略
4. 标注 E2E 场景（如有）

规范：
- 单元测试：覆盖核心逻辑分支
- 集成测试：覆盖模块间交互
- 边界测试：空值/极值/异常输入
```

**Test-Creator 输出**：测试文件骨架（`.test.ts` / `_test.py` 等）→ 传给 Step 3

---

### Step 3: Coder — TDD 编程

**目标**：按测试用例骨架 TDD 驱动实现功能代码。

**执行方式**：使用 Agent 工具 spawn coder agent。

**Coder Prompt 模板：**

```
你是高级工程师，使用 TDD 驱动实现功能。

测试文件：
{Step 2 生成的测试文件路径列表}

技术方案：
{Step 1 的输出}

TDD 循环：
1. 读取测试文件，理解期望行为
2. 运行测试，确认当前为 RED 状态
3. RED → GREEN：实现最小代码让测试通过
4. GREEN → REFACTOR：保持测试通过的前提下优化代码
5. 重复直到所有测试通过

编码规范：
- 每个函数不超过 30 行
- 公开 API 有 JSDoc / docstring
- 类型安全（TypeScript strict / Python type hints）
- 错误处理：优雅降级，不吞异常
- 提交时附带 WHAT + WHY 的 commit message
```

**Coder 输出**：功能代码 + 通过的测试 → 传给 Step 4

---

### Step 4: Reviewer — 代码评审

**目标**：多维度 Review 代码质量，决定通过或打回。

**执行方式**：使用 Agent 工具 spawn reviewer agent。

**Reviewer Prompt 模板：**

```
你是代码评审师，对本次变更进行 Review。

变更文件：
{Step 3 修改/新建的文件列表}

技术方案：
{Step 1 的输出}

Review 维度（每项 PASS / WARN / BLOCK）：
1. 正确性：逻辑无误、边界处理、空值安全
2. 可读性：命名清晰、注释到位、函数≤30行
3. 可测性：无硬编码、可 mock、测试覆盖合理
4. 性能：无 N+1、无同步阻塞、无内存泄漏
5. 安全：无注入风险、敏感信息未硬编码
6. 风格：符合项目编码规范

判定规则：
- 任一维度 BLOCK → 整体 BLOCK，回退到 Step 3 修复
- WARN 项给出改进建议，不阻塞
- 全部 PASS 或仅有 WARN → 通过

输出格式：
- 每个维度的判定 + 具体说明
- 总体判定：PASS / WARN / BLOCK
- BLOCK 项的修复建议（如适用）
```

**Reviewer 输出**：
- **PASS / WARN** → 任务完成，输出总结
- **BLOCK** → 回退到 Step 3，Coder 按修复建议修改后重新提交 Review

---

## 流转规则

```
[用户需求]
    ↓
Step 1: Planner → 技术方案
    ↓
Step 2: Test-Creator → 测试用例骨架
    ↓
Step 3: Coder → TDD 实现
    ↓
Step 4: Reviewer → 代码评审
    ├─ PASS/WARN → ✅ 完成，输出总结
    └─ BLOCK → 回退 Step 3 修复 → 重新 Step 4（最多 3 轮）
```

**回退上限**：Review BLOCK 后最多回退 3 轮。超过 3 轮仍未通过时，暂停并报告问题给用户。

---

## 完成输出

任务完成后输出：

```
✅ 编程任务完成

阶段执行结果：
  Step 1 Planner:     ✅ 技术方案已输出
  Step 2 Test-Creator: ✅ 测试用例骨架已生成
  Step 3 Coder:        ✅ TDD 实现完成（所有测试 GREEN）
  Step 4 Reviewer:     ✅ Review 通过

变更文件：
  - {新建/修改的文件列表}

测试结果：
  - {通过的测试数量} 个测试全部 GREEN
```

---

## 注意事项

1. **顺序执行**：4 个阶段严格按序执行，不可跳过或并行
2. **TDD 强制**：Coder 必须先确认测试骨架存在，按 RED→GREEN→REFACTOR 循环
3. **Review 不可跳过**：Coder 完成后必须经过 Reviewer 评审
4. **不自行生成需求**：所有任务来源于用户输入，禁止自行添加功能
5. **增量修改**：Coder 只修改必要文件，不做无关重构（Surgical Changes）
6. **简单优先**：只写解决问题所需的最小代码，不过度工程化（Simplicity First）
