# WebHarness 状态机工作流

本文档定义了 WebHarness 框架的核心状态机，规定了项目从想法到上线的完整生命周期。

> **v3 核心变更（TDD + 测试后置 + Review）：**
> - TEST 拆分为 `TEST-PLAN`（PLAN 阶段中，输出测试用例骨架）和 `TEST-RUN`（部署测试环境后执行 E2E）
> - DEPLOY 拆分为 `DEPLOY-TEST`（默认部署测试环境）和 `DEPLOY-PROD`（显式发布生产环境）
> - **新增 `REVIEW` 阶段**：编码完成后必须经过 Reviewer Agent 评审，失败则回退 CODE
> - 流程变为：**IDEA → PLAN → TEST-PLAN → CODE → REVIEW → DEPLOY-TEST → TEST-RUN → EVAL → DEPLOY-PROD → MONITOR → ARCHIVE**

---

## 状态定义

| 状态 | 英文标识 | 说明 | 负责角色 |
|------|----------|------|----------|
| **构想** | `IDEA` | 需求收集与分析阶段 | PM + Planner |
| **规划** | `PLAN` | 技术方案设计 + **TDD 测试计划** | Planner + Tester |
| **开发** | `CODE` | 功能编码，**按测试用例驱动** | Coder |
| **评审** | `REVIEW` | 代码审查（由 Reviewer Agent 执行） | **Reviewer** |
| **测试部署** | `DEPLOY-TEST` | 部署到测试环境（默认） | Deployer |
| **测试执行** | `TEST-RUN` | E2E 测试执行 + 回归验证 | Tester |
| **评估** | `EVAL` | 质量门禁与综合评分 | Evaluator |
| **生产发布** | `DEPLOY-PROD` | 部署到正式生产环境 | Deployer + PM |
| **监控** | `MONITOR` | 线上观测与持续运营 | Deployer + PM |
| **归档** | `ARCHIVE` | 版本结项与经验沉淀 | 全员 |

---

## 状态转换图（Mermaid）

```mermaid
stateDiagram-v2
    [*] --> IDEA : 新需求 / 新 Feature

    IDEA --> PLAN : 需求评审通过
    IDEA --> IDEA : 需求不明确（退回澄清）

    PLAN --> TEST-PLAN : 方案设计完成
    PLAN --> PLAN : 技术风险未解决
    PLAN --> IDEA : 方案不可行（取消/重定义）

    TEST-PLAN --> CODE : 测试用例骨架输出完成
    TEST-PLAN --> TEST-PLAN : 测试用例评审不通过

    CODE --> REVIEW : 开发完成 + 自测通过
    CODE --> CODE : Review 不通过（修复后重新提交）
    CODE --> PLAN : 需求变更 / 方案调整

    REVIEW --> DEPLOY-TEST : Review 通过（≥ 1 人 Approval）
    REVIEW --> CODE : Review 不通过（打回修复）

    DEPLOY-TEST --> TEST-RUN : 部署成功 + Health Check 通过
    DEPLOY-TEST --> DEPLOY-TEST : 部署失败 → 回滚重试

    TEST-RUN --> EVAL : 全部测试用例通过
    TEST-RUN --> CODE : 发现 Bug（修复 → 重新部署测试）
    TEST-RUN --> TEST-RUN : 回归测试失败

    EVAL --> DEPLOY-PROD : 评分 ≥ 80 (PASS)
    EVAL --> TEST-RUN : 评分 60-79 (WARN) → 修复后重测
    EVAL --> CODE : 评分 < 60 (BLOCK) → 打回重构

    DEPLOY-PROD --> MONITOR : 部署成功 + Health Check 通过
    DEPLOY-PROD --> DEPLOY-PROD : 部署失败 → 回滚到上一版本

    MONITOR --> IDEA : 新需求 / 迭代开始
    MONITOR --> ARCHIVE : 项目结项 / 版本归档

    ARCHIVE --> [*]
```

---

## 核心流程说明

### TDD 驱动流程（关键变化）

```
PLAN 阶段
  ├─ 技术方案设计
  ├─ 任务拆解
  └─ ★ 输出「测试用例骨架」← TDD 测试计划
       (测试用例 .test.ts / _test.py 文件已存在，但测试逻辑为 TODO)

CODE 阶段
  └─ Coder 按测试用例骨架 TDD 驱动实现
       (RED → GREEN → REFACTOR 循环)
       (每写一段实现，就让对应测试从 RED 变 GREEN)

REVIEW 阶段
  └─ Reviewer Agent 执行代码 Review
       (6 维度检查：正确性/可读性/可测性/性能/安全/风格)
       (BLOCK 机制：任何一项不通过则回退 CODE)

DEPLOY-TEST 阶段
  └─ Deployer 部署到测试环境
       (默认行为，除非用户显式指定 --prod)

TEST-RUN 阶段
  └─ Tester 执行 E2E + 回归测试
       (使用部署时已就绪的测试用例)
```

---

## 转换守卫规则（Guard Conditions）

### IDEA → PLAN（需求评审门）

**前置条件（全部满足才允许转换）：**
- [ ] PM 已录入需求到 Backlog
- [ ] Planner 已完成需求澄清（≤ 3 轮追问）
- [ ] 验收标准（AC）已明确定义
- [ ] 技术可行性初步确认

**转换动作：**
- 创建 `.memory/decisions.log` 条目（需求结论）
- 创建 `docs/plan/[feature-id]/` 目录

### PLAN → TEST-PLAN（方案完成门）

**前置条件：**
- [ ] 技术方案文档已完成（≥ 2 个备选方案对比）
- [ ] API 契约已定义（OpenAPI/Swagger）
- [ ] 任务已拆解为 Story + Task（含估算）
- [ ] PM 已确认优先级和排期
- [ ] 技术风险已识别并有缓解策略

**转换动作：**
- 分配给 Coder + Tester 联合准备测试计划
- Tester 开始编写测试用例骨架（`.test.ts` / `_test.py` 文件框架）

### TEST-PLAN → CODE（测试计划完成门）

**前置条件：**
- [ ] 核心功能的测试用例骨架已输出（BDD Scenario 覆盖主要路径）
- [ ] 测试用例经过 Planner + Coder 联合评审
- [ ] 测试数据准备方案已确认
- [ ] Mock/Fixture 策略已定义（禁止在 E2E 中 mock 后端）

**转换动作：**
- 创建 Issue/Task 跟踪
- 分配给 Coder
- 测试用例骨架已存在，Coder 进入 TDD 循环

### CODE → REVIEW（开发完成门）

**前置条件（全部满足才允许提交 Review）：**
- [ ] 所有 Story Task 标记 Done
- [ ] **测试用例全部为 GREEN 状态**（TDD 达标）
- [ ] Unit Test 覆盖率 ≥ 目标值（默认 80%）
- [ ] Lint + Format 全部通过
- [ ] 无 P0/P1 阻塞性 TODO
- [ ] Commit message 符合规范（WHAT + WHY）

**转换动作：**
- Coder 提交 PR/MR 到 Review 队列
- 自动通知 Reviewer Agent 开始评审

### REVIEW → DEPLOY-TEST（Review 通过门）

**前置条件：**
- [ ] **Reviewer Agent 评审完成**（必选）
- [ ] 代码变更范围合理（单次 ≤ 500 行新增/修改）
- [ ] 无明显的架构问题或性能风险
- [ ] 安全扫描无 CRITICAL/HIGH 漏洞

**Review 检查维度：**
- **正确性**：逻辑无误、边界处理完整、空值安全
- **可读性**：命名清晰、注释到位、函数长度 ≤ 30 行
- **可测性**：是否支持测试（无硬编码、可 mock）
- **性能**：无 N+1 查询、无同步大文件、无递归深渊
- **安全**：无注入风险、敏感信息未硬编码、权限检查到位

**转换动作：**
- 合并代码到测试分支
- 触发 CI 构建
- 通知 Deployer 开始测试环境部署

### DEPLOY-TEST → TEST-RUN（测试部署完成门）

**前置条件：**
- [ ] 测试环境部署成功
- [ ] Health Check 所有关键路由返回 200
- [ ] 数据库迁移已完成（如有）
- [ ] 测试环境配置（env）已加载

**转换动作：**
- 通知 Tester 开始执行 E2E 测试
- 启动测试报告收集

### TEST-RUN → EVAL（测试完成门）

**前置条件：**
- [ ] E2E 主流程 100% 通过
- [ ] 单元/集成测试全部通过
- [ ] 无 P0 Bug，P1 Bug ≤ 2 个且有 workaround
- [ ] 性能测试符合基线（LCP < 2.5s, FID < 100ms）
- [ ] 安全扫描无 CRITICAL/HIGH 漏洞
- [ ] a11y audit 得分 ≥ 90

**转换动作：**
- 生成测试报告
- 收集截图和日志证据
- 触发 Evaluator 进行综合评分

### EVAL → DEPLOY-PROD（质量放行门）

**前置条件：**
- [ ] 综合评分 ≥ 80（PASS）
- [ ] 所有质量维度无 BLOCK 项
- [ ] CHANGELOG 已更新
- [ ] 版本号符合 semver
- [ ] PM 已确认发布窗口
- [ ] 回滚方案已确认（≤ 5min RTO）
- [ ] 灰度策略已配置（如需）

**转换动作：**
- 签署发布许可
- 通知 Deployer 执行生产发布

### DEPLOY-PROD → MONITOR（上线门）

**前置条件：**
- [ ] 生产环境 Health Check 通过
- [ ] 关键业务指标（订单/登录等）无异常
- [ ] 数据库迁移脚本已执行并验证

**转换动作：**
- 通知 PM + 团队上线成功
- 开启线上监控警戒

---

## 异常回退策略

| 当前状态 | 异常场景 | 目标状态 | 处理方式 |
|----------|----------|----------|----------|
| PLAN | 技术方案不可行 | IDEA | 取消或重定义需求 |
| TEST-PLAN | 测试用例无法设计 | PLAN | 重新分析需求 |
| CODE | 需求重大变更 | PLAN | 重新进入规划流程 |
| CODE | 测试用例变 RED | CODE | TDD 循环修复 |
| **REVIEW** | **Review 不通过** | **CODE** | **修复问题后重新提交 Review** |
| DEPLOY-TEST | 部署失败 | CODE | 修复后重新部署测试 |
| TEST-RUN | 发现 Bug | CODE | 修复后重新部署测试 |
| TEST-RUN | 发现架构缺陷 | CODE | 重构后再测 |
| EVAL | BLOCK (< 60分) | CODE | 打回重构，Planner 辅助 |
| DEPLOY-PROD | 部署失败 | DEPLOY-PROD | 回滚到上一版本，重新发布 |
| MONITOR | 线上 P0 事故 | CODE | 紧急 Hotfix |

---

## 角色在各状态下的权责矩阵

| 状态 | PM | Planner | Coder | Tester | Evaluator | Deployer | **Reviewer** |
|------|----|---------|-------|--------|-----------|----------|---|
| IDEA | 👑 主导 | ⭐ 参与 | | | | | |
| PLAN | ⭐ 确认 | 👑 主导 | 💬 评审 | ⭐ 评审 | | | |
| TEST-PLAN | 📊 跟踪 | ⭐ 参与 | 💬 评审 | 👑 主导 | | | |
| CODE | 📊 跟踪 | 💬 支持 | 👑 主导 | 💬 协助 | | | |
| **REVIEW** | | | 📋 输入 | | | | **👑 主导** |
| DEPLOY-TEST | | | | 💬 协助 | | 👑 主导 | |
| TEST-RUN | 📊 跟踪 | | 💬 协助 | 👑 主导 | | | |
| EVAL | 📋 决策 | | 📋 输入 | 📋 输入 | 👑 主导 | | |
| DEPLOY-PROD | ✅ 批准 | | | ✅ 许可 | 👑 主导 | 👑 主导 | |
| MONITOR | 👁️ 关注 | | | | 👁️ 关注 | 👑 主导 | |

图例：👑主导 / ⭐参与 / 💬咨询 / 📋输入 / 📊跟踪 / ✅审批 / 👁️关注

---

## 环境配置规范

所有环境配置通过 `config.json` 中的 `environment_map` 字段管理：

```json
{
  "environment_map": {
    "test": {
      "url": "https://test-staging.myapp.com",
      "api_base": "https://test-staging.myapp.com/api",
      "database": "postgresql://test-db:5432/app_test",
      "feature_flags": { "new_feature": true }
    },
    "prod": {
      "url": "https://myapp.com",
      "api_base": "https://myapp.com/api",
      "database": "postgresql://prod-db:5432/app_prod",
      "feature_flags": { "new_feature": false }
    }
  }
}
```

### 部署命令约定

| 命令 | 行为 |
|------|------|
| `deployer deploy` | 默认部署到 **test** 环境 |
| `deployer deploy --prod` | 显式部署到 **prod** 环境 |
| `deployer deploy --env staging` | 部署到指定环境 |

---

## 状态持久化

每次状态转换必须记录到 `docs/state-log.md`：

```markdown
## [timestamp] STATE_TRANSITION

- **from**: REVIEW
- **to**: DEPLOY-TEST
- **trigger**: Reviewer Agent 评审通过
- **actor**: Reviewer (@reviewer)
- **artifacts**: docs/review/user-auth-report.md
- **guard_check**: ✅ All conditions met (6维度全部 PASS)
- **notes**: 代码质量评分 85/100，Review 通过，通知 Deployer 开始部署
```