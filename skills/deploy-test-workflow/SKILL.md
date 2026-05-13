---
name: deploy-test-workflow
description: >
  部署测试工作流编排器。按顺序编排 deployer → tester 两个阶段，依次执行测试环境部署和测试运行。
  当用户需要测试时默认使用此技能。触发词：测试、跑测试、部署测试、deploy test、run tests、
  跑一下测试、验证一下、测试环境部署、E2E、回归测试。
agent_created: true
---

# Deploy-Test-Workflow: 部署测试顺序编排

## 概述

将一次测试验证拆解为 2 个顺序阶段：

```
deployer → tester
部署测试环境   执行测试
```

前一阶段输出（部署就绪确认）作为后一阶段输入（测试前提）。

## 何时使用

- 用户提出测试相关需求时**默认使用**
- 需要部署到测试环境并运行验证
- 用户说「跑测试」「测试一下」「部署测试环境」「验证一下」「E2E」「回归测试」

**不使用此技能的场景：**
- 纯代码编写（使用 basic-code-workflow）
- 需要部署生产环境（由 web-harness 的 DEPLOY-PROD 阶段处理）
- 仅查询测试结果，不涉及部署和执行

---

## 执行流程

### 前置：确认测试范围

收到测试需求后，先快速确认：

1. **测试范围**：哪些功能 / 模块需要测试？
2. **测试类型**：E2E / 回归 / Smoke / 全量？
3. **环境信息**：测试环境地址、配置是否已有？

如果用户描述已足够清晰，直接进入 Step 1；如有歧义，先提问澄清（≤2 轮）。

---

### Step 1: Deployer — 部署测试环境

**目标**：将代码部署到测试环境，确保环境就绪。

**执行方式**：使用 Agent 工具 spawn deployer agent。

**Deployer Prompt 模板：**

```
你是部署工程师，将代码部署到测试环境。

部署目标：测试环境
测试范围：{用户需求}
技术栈：{tech_stack}

执行步骤：
1. 读取环境配置（.env.test / config.json 中的 environment_map.test）
2. 执行构建：build 项目
3. 执行部署：deploy to test environment
4. Health Check：验证关键路由返回 200
   - 主页/健康检查端点
   - API 基础路由
5. Smoke Test：3 个核心场景快速验证
   - 首页可访问
   - 登录/核心流程可达
   - API 基础 CRUD 可响应
6. 数据库迁移（如有）：确认迁移脚本已执行

输出格式：
- 部署状态：SUCCESS / FAILED
- 环境地址：{测试环境 URL}
- Health Check 结果：{各端点状态}
- Smoke Test 结果：{各场景通过/失败}
- 错误信息（如有）

失败处理：
- 部署失败 → 回滚到上一版本，报告错误原因
- Health Check 失败 → 检查日志，给出排查建议
```

**Deployer 输出**：部署就绪确认（环境地址 + Health Check 通过）→ 传给 Step 2

**失败处理**：部署失败时不进入 Step 2，直接报告错误给用户，等待修复后重试。

---

### Step 2: Tester — 执行测试

**目标**：在测试环境上运行测试用例，输出测试报告。

**前置条件**：Step 1 部署成功 + Health Check 通过。

**执行方式**：使用 Agent 工具 spawn tester agent。

**Tester Prompt 模板：**

```
你是测试工程师，在测试环境上执行测试。

测试环境：{Step 1 输出的环境地址}
测试范围：{用户需求}
测试类型：{E2E / 回归 / Smoke / 全量}

执行步骤：
1. 确认测试环境可用（Health Check）
2. 运行单元测试 + 集成测试
3. 运行 E2E 测试（Playwright / Cypress）
   - 主流程 100% 覆盖：登录/CRUD/核心业务/退出
   - 边界场景：空数据/异常输入/并发
   - 回归场景：已有功能的正确性验证
4. 运行安全扫描（如适用）
5. 汇总测试结果

测试规范：
- E2E 禁止 mock 后端 API，使用真实 HTTP 请求
- 使用测试环境真实数据（fixture / seeder）
- 每个失败用例必须有：严重度 + 重现步骤 + 预期行为

输出格式：
- 测试总数：X
- 通过：X（GREEN）
- 失败：X（RED）
- 跳过：X
- 覆盖率：X%
- 失败用例详情：
  - [P0/P1/P2] 用例名 → 重现步骤 → 预期 vs 实际
- 性能指标（如适用）：LCP / FID / CLS

判定：
- 全部通过 → PASS
- 有 P1+ Bug → WARN（给出 workaround）
- 有 P0 Bug → BLOCK
```

**Tester 输出**：测试报告（PASS / WARN / BLOCK）

---

## 流转规则

```
[用户测试需求]
    ↓
Step 1: Deployer → 部署测试环境
    ├─ SUCCESS → Step 2
    └─ FAILED → ❌ 报告错误，等待用户修复后重试
    ↓
Step 2: Tester → 执行测试
    ├─ PASS → ✅ 测试通过，输出报告
    ├─ WARN → ⚠️ 测试通过但有警告，输出改进建议
    └─ BLOCK → ❌ 测试阻断，输出 P0 Bug 详情，建议修复后重新执行
```

**重试上限**：部署失败最多重试 2 次。超过 2 次仍未成功时，暂停并报告问题给用户。

---

## 完成输出

测试完成后输出：

```
🧪 部署测试完成

阶段执行结果：
  Step 1 Deployer:  ✅ 测试环境部署成功
  Step 2 Tester:    ✅/⚠️/❌ 测试结果

测试环境：{URL}
测试结果：
  通过：X / 失败：X / 跳过：X
  覆盖率：X%
  判定：PASS / WARN / BLOCK

{如有失败用例，列出详情}
{如有 WARN 项，列出改进建议}
```

---

## 注意事项

1. **顺序执行**：必须先部署再测试，不可跳过部署阶段
2. **默认测试环境**：deploy 默认部署到测试环境，不涉及生产
3. **E2E 禁止 mock 后端**：测试阶段必须使用真实后端
4. **部署失败不继续**：Step 1 失败则不进入 Step 2
5. **不自行修复代码**：发现 Bug 时报告给用户，由用户决定是否进入 basic-code-workflow 修复
