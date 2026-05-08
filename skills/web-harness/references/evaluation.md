# WebHarness WebApp 评估体系

本文档定义了针对 Web 应用的多维度质量评估能力。这是 Evaluator 角色的核心执行标准。

---

## 评估维度总览

```
                    ┌─────────────────────┐
                    │   综合质量评分       │
                    │  (0 - 100)          │
                    └──────────┬──────────┘
         ┌──────────┬──────────┼──────────┬──────────┐
         ▼          ▼          ▼          ▼          ▼
    ┌─────────┐┌─────────┐┌─────────┐┌─────────┐┌─────────┐
    │ 功能正确性││ UI/UX  ││ 性能指标││ 安全性  ││代码质量 │
    │  30%    ││  20%   ││  20%   ││  15%   ││  15%   │
    └─────────┘└─────────┘└─────────┘└─────────┘└─────────┘
```

---

## 维度一：功能正确性（权重 30%）

### 评估项

| # | 检查项 | 权重 | 检测方式 | PASS 标准 |
|---|--------|------|----------|-----------|
| 1.1 | 用户故事覆盖 | 20% | 对照 Story AC 逐条验证 | 100% AC 有对应测试 |
| 1.2 | API 契约符合度 | 25% | OpenAPI diff + 契约测试 | Request/Response 100% 符合 spec |
| 1.3 | 业务逻辑准确性 | 25% | E2E 关键路径测试 | 核心流程 0 失败 |
| 1.4 | 边界条件处理 | 15% | 边界值分析 + 异常注入 | 空/零/溢出/超长 全覆盖 |
| 1.5 | 数据一致性 | 15% | 状态校验 + 并发测试 | 无脏读/丢失更新 |

### 自动化工具
- **契约测试**：Pact / OpenAPI Validator
- **E2E**：Playwright（无 mock，真实 API）
- **边界测试**：基于属性生成（Hypothesis / fast-check）

---

## 维度二：UI/UX 质量（权重 20%）

### 评估项

| # | 检查项 | 权重 | 检测方式 | PASS 标准 |
|---|--------|------|----------|-----------|
| 2.1 | 响应式布局 | 25% | 多设备截图对比 | mobile/tablet/desktop 无错位 |
| 2.2 | 可访问性 (a11y) | 30% | axe-core WCAG 2.1 AA | 得分 ≥ 95，0 critical |
| 2.3 | 交互流畅度 | 20% | Chrome Performance | FPS ≥ 55, FID < 100ms |
| 2.4 | 视觉一致性 | 15% | 截图回归 (Pixelmatch) | 差异像素 < 0.1% |
| 2.5 | 国际化/本地化 | 10% | i18n 键完整性检查 | 无硬编码文本、RTL 支持 |

### 自动化工具
- **a11y**：`@axe-core/playwright`
- **视觉回归**：Playwright screenshots + pixelmatch
- **响应式**：Chrome DevTools Protocol 模拟多设备
- **Lighthouse**：CI 集成审计

### Web Vitals 基线

| 指标 | 好 | 需改进 | 差 | 基线要求 |
|------|-----|--------|-----|----------|
| LCP | ≤ 2.5s | 2.5s-4s | > 4s | ≤ 2.5s |
| FID | ≤ 100ms | 100-300ms | > 300ms | ≤ 100ms |
| CLS | ≤ 0.1 | 0.1-0.25 | > 0.25 | ≤ 0.1 |
| INP | ≤ 200ms | 200-500ms | > 500ms | ≤ 200ms |

---

## 维度三：性能指标（权重 20%）

### 评估项

| # | 检查项 | 权重 | 检测方式 | PASS 标准 |
|---|--------|------|----------|-----------|
| 3.1 | 首屏加载 | 30% | Lighthouse CI | LCP ≤ 2.5s, FCP ≤ 1.8s |
| 3.2 | 包体积控制 | 20% | bundle analyzer | JS ≤ 200KB (gzipped) |
| 3.3 | API 响应时间 | 20% | k6 负载测试 | p50 < 200ms, p99 < 1s |
| 3.4 | 渲染性能 | 15% | Chrome Tracing | Long Task < 50ms |
| 3.5 | 缓存策略 | 15% | Headers 检查 | 静态资源 max-age ≥ 30d |

### 分级标准

| 场景 | 并发用户 | 目标响应时间 | 可用率 |
|------|----------|-------------|--------|
| 正常负载 | 100 | p99 < 1s | 99.9% |
| 高峰负载 | 500 | p99 < 2s | 99.5% |
| 压力极限 | 2000 | p95 < 5s | 99% |

---

## 维度四：安全性（权重 15%）

### 评估项

| # | 检查项 | 权重 | 检测方式 | PASS 标准 |
|---|--------|------|----------|-----------|
| 4.1 | OWASP Top 10 | 35% | SAST (ESLint-security/Semgrep) | 0 HIGH/CRITICAL |
| 4.2 | 依赖漏洞 | 25% | npm audit / pip-audit / Snyk | 0 CRITICAL, HIGH ≤ 2 |
| 4.3 | 认证鉴权 | 20% | 手工 + 自动化扫描 | JWT/Session 安全校验通过 |
| 4.4 | 数据保护 | 12% | 敏感数据扫描 | 无硬编码密钥/PII 泄露 |
| 4.5 | CORS/CSP 配置 | 8% | Header 审计 | 策略合理不过于宽松 |

### 必查安全清单 (Security Checklist)

- [ ] SQL 注入防护（参数化查询 / ORM）
- [ ] XSS 防护（输出转义 / CSP / Nonce）
- [ ] CSRF 防护（Token / SameSite）
- [ ] 认证：密码哈希（bcrypt/argon2）、MFA 支持
- [ ] 授权：RBAC 最小权限原则
- [ ] 速率限制（Rate Limiting）：auth 10/min, api 100/min
- [ ] 日志脱敏：不记录密码/token/PII
- [ ] HTTPS 强制：生产环境 HSTS
- [ ] 环境变量管理：无硬编码密钥进仓库

---

## 维度五：代码质量（权重 15%）

### 评估项

| # | 检查项 | 权重 | 检测方式 | PASS 标准 |
|---|--------|------|----------|-----------|
| 5.1 | 复杂度控制 | 25% | ESLint cyclomatic-complexity / radar | 圈复杂度 ≤ 10/函数 |
| 5.2 | 测试覆盖率 | 30% | istanbul/covertura | 行覆盖率 ≥ 80%, 分支 ≥ 70% |
| 5.3 | 代码规范 | 20% | Lint + Format check | 0 error, 0 warning |
| 5.4 | 技术债密度 | 15% | SonarQube / CodeClimate | Tech Debt Ratio < 5% |
| 5.5 | 类型安全 | 10% | TypeScript strict / pyright | any 使用 < 2%, type errors = 0 |

---

## 评分计算引擎

```python
# 伪代码 — 评分算法
def calculate_score(dimensions: dict) -> dict:
    """
    dimensions = {
        "functionality": {"score": 85, "weight": 0.30},
        "uiux":           {"score": 90, "weight": 0.20},
        "performance":    {"score": 75, "weight": 0.20},
        "security":       {"score": 95, "weight": 0.15},
        "code_quality":   {"score": 80, "weight": 0.15},
    }
    """
    weighted_total = sum(d["score"] * d["weight"] for d in dimensions.values())
    
    # 判定等级
    if weighted_total >= 90:
        grade = "A+ 🏆"
    elif weighted_total >= 80:
        grade = "A ✅"
    elif weighted_total >= 70:
        grade = "B ⚠️"
    elif weighted_total >= 60:
        grade = "C 🔶"
    else:
        grade = "F 🚫"
    
    # 门禁判定
    if weighted_total >= 80:
        gate = "PASS"      # 允许部署
    elif weighted_total >= 60:
        gate = "WARN"      # 警告但可放行（需 PM 确认）
    else:
        gate = "BLOCK"     # 阻止部署
    
    return {
        "total": round(weighted_total, 1),
        "grade": grade,
        "gate": gate,
        "dimensions": {k: v["score"] for k, v in dimensions.items()},
        "trend": get_trend_vs_last_eval()  # 与上次对比
    }
```

### 评级说明

| 等级 | 分数范围 | 含义 | 操作 |
|------|----------|------|------|
| **A+** 🏆 | 90-100 | 卓越 | 可以作为标杆案例 |
| **A** ✅ | 80-89 | 优秀 | 通过门禁，允许部署 |
| **B** ⚠️ | 70-79 | 良好 | 需关注，PM 确认后可部署 |
| **C** 🔶 | 60-69 | 及格边缘 | 需要列出改进计划 |
| **F** 🚫 | 0-59 | 不合格 | 阻止部署，打回修复 |

---

## 评估报告模板

每次评估必须生成如下结构的报告：

```markdown
# 质量评估报告

## 元信息
- **项目**: [project-name]
- **版本**: v[X.Y.Z]
- **分支**: [branch-name]
- **Commit**: [sha]
- **评估时间**: [ISO 8601]
- **评估人**: Evaluator (AI Agent)

## 总分: [XX.X] / 100 ([GRADE]) → [PASS/WARN/BLOCK]

## 各维度得分

| 维度 | 得分 | 权重 | 加权分 | 趋势(vs 上次) | 状态 |
|------|------|------|--------|---------------|------|
| 功能正确性 | XX | 30% | XX.X | ↑/↓/→ | ✅/⚠️/❌ |
| UI/UX | XX | 20% | XX.X | ↑/↓/→ | ✅/⚠️/❌ |
| 性能 | XX | 20% | XX.X | ↑/↓/→ | ✅/⚠️/❌ |
| 安全性 | XX | 15% | XX.X | ↑/↓/→ | ✅/⚠️/❌ |
| 代码质量 | XX | 15% | XX.X | ↑/↓/→ | ✅/⚠️/❌ |

## 详细发现

### ✅ 通过项 (N 项)
...

### ⚠️ 警告项 (N 项)
| # | 维度 | 描述 | 建议 | 工时估算 |
|---|------|------|------|----------|

### ❌ 阻塞项 (N 项) [如有则 BLOCK]
| # | 维度 | 描述 | 严重程度 | 修复建议 |

## 改进建议 Top 5
1. ...
2. ...
3. ...
4. ...
5. ...

## 趋势图（最近 N 次评估）
[ASCII 或 Mermaid 图表]
```
