# WebHarness 验证机制（质量门禁系统）

本文档定义了多层质量门禁规则，确保每个阶段的交付物都达到预期标准。

> **v2 核心变更：** 门禁与状态机对齐，新增 TEST-PLAN、DEPLOY-TEST、TEST-RUN、DEPLOY-PROD 四个门禁节点，实现 TDD 驱动 + 测试后置。

---

## 门禁层级总览

```
状态对齐的六层门禁（v2）
┌──────────────────┐
│  TEST-PLAN Gate  │  ← PLAN→CODE 前：测试用例骨架评审
│  ~10 分钟        │
└────────┬─────────┘
         ↓
┌──────────────────┐
│  DEPLOY-TEST     │  ← CODE→TEST-RUN 前：部署到测试环境 + Health Check
│  ~5 分钟         │
└────────┬─────────┘
         ↓
┌──────────────────┐
│  TEST-RUN Gate   │  ← DEPLOY-TEST 后：全量 E2E + 回归（无 mock）
│  ~15 分钟        │
└────────┬─────────┘
         ↓
┌──────────────────┐
│  EVAL Gate       │  ← TEST-RUN→DEPLOY-PROD 前：综合评分判定
│  ~5 分钟         │
└────────┬─────────┘
         ↓
┌──────────────────┐
│  DEPLOY-PROD     │  ← 上线前：灰度 + 回滚策略 + PM 审批
│  ~10 分钟        │
└────────┬─────────┘
         ↓
┌──────────────────┐
│  MONITOR Gate    │  ← 部署后 30 分钟：业务指标 + P0 告警
│  ~30 分钟        │
└──────────────────┘

前置门禁（始终运行）
Commit Gate (~30s) → PR Gate (~5min) → [TEST-PLAN Gate]
```

---

## Level 1：Commit 级门禁（~30 秒）

**目标**：保证每一次提交都不会破坏基本构建。

**触发时机**：每次 `git push` 或 PR 创建时自动触发。

### 检查清单

| # | 检查项 | 工具 | 严格度 | 失败处理 |
|---|--------|------|--------|----------|
| 1.1 | 代码风格 (Lint) | ESLint / Pylint / Ruff | **BLOCK** | PR 无法合并 |
| 1.2 | 代码格式化 | Prettier / Black | **BLOCK** | auto-fix 后 re-push |
| 1.3 | 单元测试 | vitest / pytest | **BLOCK** | 新增代码需有测试覆盖 |
| 1.4 | Type 检查 | tsc --noEmit / pyright | **BLOCK** | 类型错误必须修复 |
| 1.5 | Commit Message | commitlint | WARN | 不阻止但标记不规范 |
| 1.6 | 文件大小限制 | custom script | WARN | 单文件 < 500 行 (新文件) |
| 1.7 | 无敏感信息 | git-secrets / trufflehog | **BLOCK** | 检测到密钥/Token 立即阻断 |

---

## Level 2：PR 级门禁（~5 分钟）

**目标**：确保合入主分支的代码经过充分验证。

**触发时机**：PR 准备合并前（或 label 为 `ready-to-merge` 时）。

### 检查清单

| # | 检查项 | 工具 | 严格度 | 失败处理 |
|---|--------|------|--------|----------|
| 2.1 | 全量单元+集成测试 | vitest / pytest | **BLOCK** | 覆盖率不达标不能合并 |
| 2.2 | 测试覆盖率门槛 | istanbul / coverage | **BLOCK** | 新增代码 Δcoverage ≥ 80% |
| 2.3 | 安全扫描 | Snyk / CodeQL / Semgrep | **BLOCK** | CRITICAL/HIGH 必须修 |
| 2.4 | Code Review | GitHub Review / CR Bot | **BLOCK** | 至少 1 Approval, 0 Change Request |
| 2.5 | 构建产物检查 | build script | **BLOCK** | 生产构建成功 |
| 2.6 | API 契约验证 | Pact / openapi-diff | WARN | Breaking Change 需要明确标注 |

---

## Level 3：TEST-PLAN Gate（~10 分钟）★ 新增

**目标**：确保测试用例骨架在编码之前完成评审，TDD 流程有据可依。

**触发时机**：PLAN → CODE 状态转换前。

### 检查清单

| # | 检查项 | 工具 | 严格度 | 失败处理 |
|---|--------|------|--------|----------|
| 3.1 | 核心场景 BDD Scenario | 评审文件存在性 | **BLOCK** | 测试骨架文件未生成则阻断 |
| 3.2 | 测试用例骨架评审 | Coder + Tester 联合签字 | **BLOCK** | 未评审不能进入 CODE |
| 3.3 | 测试数据方案 | Fixture/Mock 数据定义 | WARN | 数据缺失记入技术债 |
| 3.4 | E2E 无 Mock 策略确认 | Playwright/Cypress 配置 | **BLOCK** | E2E 禁止 mock 后端 API |
| 3.5 | 测试覆盖目标 | 覆盖率目标定义 | WARN | 低于 80% 需 PM 确认 |

### 测试用例骨架规范

```typescript
// ✅ 正确：骨架存在，测试逻辑为 TODO（RED 状态，TDD 起点）
describe('用户登录', () => {
  it('输入正确凭证后成功登录', async () => {
    // TODO: 实现登录逻辑，让此测试从 RED → GREEN
    expect(true).toBe(false) // RED: 占位，驱动开发
  })

  it('输入错误密码后显示错误提示', async () => {
    // TODO: 实现错误处理
    expect(true).toBe(false)
  })

  it('Token 过期后自动刷新', async () => {
    // TODO: 实现 token 刷新
    expect(true).toBe(false)
  })
})
```

---

## Level 4：DEPLOY-TEST Gate（~5 分钟）★ 新增

**目标**：验证代码成功部署到测试环境，Health Check 通过。

**触发时机**：CODE → DEPLOY-TEST 状态转换时，以及 DEPLOY-TEST → TEST-RUN 之间。

### 检查清单

| # | 检查项 | 工具 | 严格度 | 失败处理 |
|---|--------|------|--------|----------|
| 4.1 | 测试环境 Health Check | curl / Postman | **BLOCK** | 所有关键路由 200 |
| 4.2 | 数据库迁移 | migrate up + verify | **BLOCK** | 迁移失败则回滚 |
| 4.3 | 环境变量加载 | env 检查脚本 | **BLOCK** | 缺少配置则阻断 |
| 4.4 | 前端构建 | npm run build / python build | **BLOCK** | 构建失败不部署 |
| 4.5 | 测试数据就绪 | Fixture 加载验证 | WARN | 数据缺失测试可降级跑 |

### 测试环境配置模板

```yaml
# .env.test
NODE_ENV=test
API_BASE_URL=https://test-staging.myapp.com/api
DATABASE_URL=postgresql://test-db:5432/app_test
REDIS_URL=redis://test-redis:6379/0
LOG_LEVEL=debug
ENABLE_MOCK=false  # 严禁 mock，E2E 必须真实
FEATURE_FLAGS={"new_login": true, "v2_api": false}
```

### DEPLOY-TEST 命令

```bash
# 默认部署到测试环境
deployer deploy
# 或显式指定
deployer deploy --env test
deployer deploy --env staging
```

---

## Level 5：TEST-RUN Gate（~15 分钟，原 Release 级）★ 重命名

**目标**：部署到测试环境后，执行全量 E2E + 性能 + a11y 验证。

**触发时机**：DEPLOY-TEST 完成后，TEST-RUN → EVAL 之前。

> **注意：** 此门禁在**测试环境**执行，不在本地。E2E 必须走真实 HTTP 链路，禁止任何 mock/stub/fake。

### 检查清单

| # | 检查项 | 工具 | 严格度 | 失败处理 |
|---|--------|------|--------|----------|
| 5.1 | E2E 回归测试 | Playwright (无 mock) | **BLOCK** | 关键路径 P0 0 失败 |
| 5.2 | 性能基线对比 | Lighthouse CI / k6 | **BLOCK** | 退化超阈值阻断 |
| 5.3 | Smoke Test | 健康检查脚本 | **BLOCK** | 核心功能可用 |
| 5.4 | a11y 审计 | axe-core | WARN | 得分 < 90 需记录技术债 |
| 5.5 | 视觉回归 | Playwright screenshots | WARN | 差异需人工确认 |
| 5.6 | 兼容性测试 | BrowserStack / LT | **BLOCK** | 目标浏览器矩阵全通过 |
| 5.7 | 数据库迁移验证 | migrate + rollback test | **BLOCK** | 迁移可逆且无损 |
| 5.8 | CHANGELOG 完整性 | changelog checker | **BLOCK** | 所有 user-facing 变更已记录 |

### E2E 测试关键路径（必测）

任何 WebApp 发布 **至少** 覆盖以下关键路径：

| # | 用户路径 | 优先级 | 测试方法 |
|---|----------|--------|----------|
| 1 | 注册/登录流程 | P0 | 完整表单提交 + 验证 |
| 2 | 核心功能 CRUD | P0 | Create → Read → Update → Delete |
| 3 | 搜索与过滤 | P0 | 输入 → 结果 → 排序 |
| 4 | 分页与加载更多 | P1 | 边界页码/空状态 |
| 5 | 文件上传/下载 | P1 | 大文件/断网/取消 |
| 6 | 权限边界 | P0 | 未授权访问被拒绝 |
| 7 | 错误场景 | P1 | 404/500/网络异常的优雅降级 |
| 8 | 移动端适配 | P1 | 触摸交互 + 视口切换 |

---

## Level 6：DEPLOY-PROD Gate（~10 分钟）★ 新增

**目标**：生产发布前的最后一道门禁，确保灰度、回滚策略就绪。

**触发时机**：EVAL → DEPLOY-PROD 状态转换时。

### 检查清单

| # | 检查项 | 工具 | 严格度 | 失败处理 |
|---|--------|------|--------|----------|
| 6.1 | PM 发布审批 | 审批记录 | **BLOCK** | 无审批不能上线 |
| 6.2 | 回滚方案就绪 | rollback.sh 存在且可执行 | **BLOCK** | 回滚脚本失败则阻断 |
| 6.3 | 灰度策略配置 | Feature Flag / 流量比例 | WARN | 无灰度需 PM 确认 |
| 6.4 | 生产数据备份 | 备份快照时间戳 | **BLOCK** | 超过 24h 未备份则阻断 |
| 6.5 | 监控告警开启 | 告警规则激活 | **BLOCK** | 无告警不能上线 |
| 6.6 | 发布窗口确认 | 时间窗口检查 | WARN | 非窗口期发布需额外审批 |
| 6.7 | 变更通知 | 团队通知已发送 | WARN | 上线后 5 分钟内通知 |

### 生产环境配置模板

```yaml
# .env.production / .env.prod
NODE_ENV=production
API_BASE_URL=https://myapp.com/api
DATABASE_URL=postgresql://prod-db:5432/app_prod
REDIS_URL=redis://prod-redis:6379/0
LOG_LEVEL=info
ENABLE_MOCK=false
FEATURE_FLAGS={"new_login": false, "v2_api": true}
# 新功能默认灰度 0%，通过 Feature Flag 控制
```

### 发布命令约定

```bash
# 测试环境（默认）
deployer deploy
deployer deploy --env test

# 生产环境（显式，必须过 DEPLOY-PROD Gate）
deployer deploy --prod
# 或
deployer deploy --env prod
```

### 灰度发布策略

| 策略 | 适用场景 | 实施方式 |
|------|---------|---------|
| 流量比例灰度 | 新功能全量 | Feature Flag 控制 0%→10%→50%→100% |
| 用户群体灰度 | 付费用户优先 | 按用户标签/租户 ID 切流 |
| 地域灰度 | 局部验证 | 按地区/机房切流 |
| 蓝绿部署 | 大版本升级 | 双倍资源，流量一键切换 |
| 金丝雀 | 高风险变更 | 5% 流量验证，指标无异常后全量 |

### 回滚策略

| RTO（目标） | ≤ 5 分钟 | 操作 |
|------------|---------|------|
| 步骤 1 | 0-1min | 执行 `deployer rollback` 切换到上一版本 |
| 步骤 2 | 1-2min | Health Check 验证回滚成功 |
| 步骤 3 | 2-3min | 通知团队 + PM |
| 步骤 4 | 3-5min | 根因分析，启动 Hotfix |

```bash
# 回滚到上一版本
deployer rollback

# 回滚到指定版本
deployer rollback --version 1.2.3

# 查看可回滚版本列表
deployer rollback --list
```

---

## Level 7：MONITOR Gate（~30 分钟）

**目标**：部署后持续观测，确保业务指标正常。

**触发时机**：DEPLOY-PROD 完成后进入 MONITOR 状态，持续 30 分钟。

### 检查清单

| # | 检查项 | 阈值 | 失败处理 |
|---|--------|------|----------|
| 7.1 | HTTP 错误率 | < 0.1% | > 1% 触发 P1 告警 |
| 7.2 | API 响应时间 P99 | < 500ms | > 1s 触发 P1 告警 |
| 7.3 | 核心功能可用性 | 99.5% | < 99% 触发 P0 告警 |
| 7.4 | 业务指标正常 | 无异常峰值/谷值 | PM + Deployer 介入 |
| 7.5 | 日志无 ERROR | ERROR rate = 0 | 有 ERROR 立即告警 |

---

## 门禁判定引擎

### 三级判决逻辑

```python
# 伪代码 — 门禁判定
def evaluate_gate(level: str, checks: list[CheckResult]) -> GateVerdict:
    """
    checks = [
        CheckResult(name="Lint", status="pass", severity="block"),
        CheckResult(name="Secret Scan", status="fail", severity="block"),
        ...
    ]
    """
    
    blocks_failed = [c for c in checks if c.severity == "block" and c.status == "fail"]
    warns_failed  = [c for c in checks if c.severity == "warn"  and c.status == "fail"]
    
    if blocks_failed:
        return GateVerdict(
            verdict="BLOCK",
            reason=f"阻塞项: {[c.name for c in blocks_failed]}",
            can_force=False,  # 不允许强制通过
            actions=[Fix(c) for c in blocks_failed]
        )
    elif warns_failed:
        return GateVerdict(
            verdict="WARN",
            reason=f"警告项: {[c.name for c in warns_failed]}",
            can_force=True,  # PM 可确认后放行
            actions=[Acknowledge(c) for c in warns_failed],
            condition="pm_approval_required"
        )
    else:
        return GateVerdict(
            verdict="PASS",
            reason="所有门禁检查通过",
            can_force=True,
            actions=[]
        )
```

### 判决结果处理

| 判决 | 含义 | 流程 |
|------|------|------|
| **PASS** ✅ | 所有检查通过 | 进入下一阶段 |
| **WARN** ⚠️ | 有警告项但无阻塞 | PM 确认后可继续；警告记入技术债 |
| **BLOCK** 🚫 | 存在阻塞项 | **停止流水线**，通知相关角色修复后重新触发 |

### 紧急 Hotfix 通道

生产 P0 故障时，可走紧急通道：

1. PM 发起紧急发布申请（附事故单号）
2. 跳过 TEST-RUN Gate（保留 Commit + PR Gate + DEPLOY-TEST Smoke Test）
3. DEPLOY-PROD Gate 仅保留：Health Check + Rollback 可执行性
4. MONITOR Gate 压缩为 15 分钟高频检查
5. 事后 24h 内补齐所有跳过的检查
6. 记录到 `docs/post-mortem/`

### 判决结果处理

| 判决 | 含义 | 流程 |
|------|------|------|
| **PASS** ✅ | 所有检查通过 | 进入下一阶段 |
| **WARN** ⚠️ | 有警告项但无阻塞 | PM 确认后可继续；警告记入技术债 |
| **BLOCK** 🚫 | 存在阻塞项 | **停止流水线**，通知相关角色修复后重新触发 |

---

## 门禁配置文件

项目根目录下的 `.gates.yml` 定义所有门禁规则：

```yaml
# .gates.yml — WebHarness 质量门禁配置（v2）
version: "2.0"

# 前置门禁
levels:
  commit:
    timeout: "30s"
    checks:
      - name: lint
        tool: eslint / ruff
        severity: block
      - name: format
        tool: prettier / black
        severity: block
      - name: unit-test
        tool: vitest / pytest
        severity: block
        params:
          min_coverage_delta: 80
      - name: type-check
        tool: tsc / pyright
        severity: block
      - name: secret-scan
        tool: trufflehog
        severity: block
      - name: commit-msg
        tool: commitlint
        severity: warn

  pr:
    timeout: "5m"
    requires_commit_gate: true
    checks:
      - name: full-test
        tool: vitest / pytest
        severity: block
        params:
          coverage_threshold: 80
      - name: security
        tool: snyk / codeql
        severity: block
      - name: code-review
        tool: github-review-api
        severity: block
        params:
          min_approvers: 1
          block_change_requests: true
      - name: build
        tool: npm run build / python -m build
        severity: block

# 状态对齐门禁（v2 新增）
  test-plan:
    timeout: "10m"
    requires_pr_gate: true
    checks:
      - name: test-skeleton
        tool: file-existence
        severity: block
        params:
          pattern: "tests/**/*.test.{ts,py}"
      - name: test-review
        tool: sign-off
        severity: block
        params:
          required_signers: [coder, tester]
      - name: no-mock-policy
        tool: config-check
        severity: block
        params:
          key: "ENABLE_MOCK"
          expected: "false"
      - name: coverage-target
        tool: threshold
        severity: warn
        params:
          min: 80

  deploy-test:
    timeout: "5m"
    requires_test_plan_gate: true
    checks:
      - name: health-check
        tool: curl / http health
        severity: block
        env: test
      - name: db-migration
        tool: migrate-verify
        severity: block
        env: test
      - name: env-vars
        tool: env-check
        severity: block
        env: test
      - name: build-artifact
        tool: build-verify
        severity: block

  test-run:
    timeout: "15m"
    requires_deploy_test_gate: true
    checks:
      - name: e2e-regression
        tool: playwright
        severity: block
        params:
          mode: no-mock
          critical_paths_only: false
      - name: performance
        tool: lighthouse-ci / k6
        severity: block
        params:
          lcp_budget_ms: 2500
          regression_threshold_pct: 10
      - name: smoke-test
        tool: scripts/smoke-test.sh
        severity: block
        env: test
      - name: accessibility
        tool: axe-core
        severity: warn
        params:
          min_score: 90
      - name: db-migration-verify
        tool: migrate-verify
        severity: block
      - name: changelog
        tool: changelog-checker
        severity: block

  deploy-prod:
    timeout: "10m"
    requires_test_run_gate: true
    checks:
      - name: pm-approval
        tool: approval-record
        severity: block
      - name: rollback-ready
        tool: script-exists
        severity: block
        params:
          script: "scripts/rollback.sh"
      - name: feature-flags
        tool: flag-config
        severity: warn
      - name: backup-verified
        tool: backup-check
        severity: block
        params:
          max_age_hours: 24
      - name: monitoring-enabled
        tool: alert-check
        severity: block
      - name: change-notification
        tool: notify-check
        severity: warn

  monitor:
    timeout: "30m"
    requires_deploy_prod_gate: true
    checks:
      - name: error-rate
        tool: metric-check
        severity: block
        params:
          metric: http_errors_rate
          threshold: 0.001
      - name: latency-p99
        tool: metric-check
        severity: block
        params:
          metric: api_latency_p99_ms
          threshold: 500
      - name: availability
        tool: metric-check
        severity: block
        params:
          metric: availability_pct
          threshold: 99.5

hotfix:
  skip_checks:
    - test-run          # 改为 3 条关键路径
    - test-plan         # 跳过
    - deploy-prod-a11y  # 跳过
    - changelog         # 事后补齐
  always_required:
    - lint
    - unit-test
    - security
    - deploy-test-smoke
    - rollback-ready
    - pm-approval
  post_hoard_deadline: "24h"
```
