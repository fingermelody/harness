# WebHarness 监控机制

本文档定义了 WebApp 项目从开发到生产的全方位监控方案。

---

## 监控架构总览

```
┌─────────────────────────────────────────────────────────┐
│                    监控仪表板 (Dashboard)                  │
│  ┌──────────┬──────────┬──────────┬──────────┬────────┐  │
│  │ 应用健康  │ 性能指标  │ 错误追踪  │ 业务指标  │ 告警   │  │
│  └──────────┴──────────┴──────────┴──────────┴────────┘  │
├─────────────────────────────────────────────────────────┤
│                      数据采集层                            │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────────┐  │
│  │  Health EP   │  │ APM Agent   │  │ Custom Metrics   │  │
│  │  /healthz    │  │ Sentry/DD   │  │ Prometheus/      │  │
│  │  /ready      │  │             │  │ Grafana          │  │
│  └─────────────┘  └─────────────┘  └──────────────────┘  │
├─────────────────────────────────────────────────────────┤
│                      告警引擎                              │
│  ┌───────────────────────────────────────────────────┐  │
│  │ info → Slack/钉钉    warn → 邮件+IM    crit → 电话 │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 一、应用层监控

### 1.1 Health Endpoint 规范

每个 WebApp **必须** 实现 `/api/health` 端点：

```typescript
// 标准 Health Check Response Schema
interface HealthResponse {
  status: "healthy" | "degraded" | "unhealthy";
  timestamp: string;           // ISO 8601
  version: string;             // semver
  uptime: number;              // seconds
  checks: {
    database: { status: "up" | "down", latency_ms: number };
    redis:    { status: "up" | "down", latency_ms: number };
    external_api: { status: "up" | "down" | "degraded", latency_ms: number };
    disk:     { status: "ok" | "warning", usage_percent: number };
    memory:   { status: "ok" | "warning", usage_percent: number };
  };
}
```

**Health Check 层级：**

| 端点 | 用途 | 返回内容 | 调用方 |
|------|------|----------|--------|
| `/api/health/live` | Liveness Probe | `{ ok: true }` | K8s / Load Balancer |
| `/api/health/ready` | Readiness Probe | 含下游依赖状态 | K8s Service Mesh |
| `/api/health/full` | 完整诊断 | 全部组件详情 | DevOps / On-call |

**响应时间要求：**
- live: < 10ms（纯内存检查）
- ready: < 100ms（含依赖 ping）
- full: < 500ms（含深度检查）

### 1.2 核心应用指标

| 指标名称 | 类型 | 单位 | 告警阈值 | 说明 |
|----------|------|------|----------|------|
| `http_requests_total` | Counter | 次 | - | 按 method/endpoint/status 分 |
| `http_request_duration_seconds` | Histogram | 秒 | p99 > 3s | 响应时间分布 |
| `http_errors_total` | Counter | 次 | 5xx 增速 > 10/min | HTTP 5xx 错误计数 |
| `active_connections` | Gauge | 个 | > 1000 | 当前活跃连接数 |
| `request_payload_bytes` | Histogram | 字节 | - | 请求体大小（检测异常大请求） |

### 1.3 结构化日志规范

**日志格式**：JSON structured logging

**必须包含字段：**

```json
{
  "timestamp": "2026-05-07T20:00:00Z",
  "level": "info",
  "service": "webapp-api",
  "version": "1.2.0",
  "trace_id": "abc123",
  "span_id": "def456",
  "user_id": "u_789",
  "message": "User login successful",
  "method": "POST",
  "/path": "/api/auth/login",
  "status_code": 200,
  "duration_ms": 45,
  "extra": {}
}
```

**日志级别使用规范：**

| 级别 | 使用场景 | 示例 |
|------|----------|------|
| `error` | 请求失败/不可恢复的错误 | DB 连接失败、第三方 API 超时 |
| `warn` | 可恢复的异常/需要注意的情况 | 重试成功、降级服务、参数接近边界 |
| `info` | 关键业务节点 | 用户登录、订单创建、支付完成 |
| `debug` | 开发调试信息（生产默认关闭） | 详细的中间状态、SQL 查询 |

**严禁在日志中记录：**
- ❌ 密码 / Token / Session ID
- ❌ 信用卡号 / PII 明文
- ❌ 完整的请求体（仅记录 size 和 hash）

---

## 二、基础设施层监控

### 2.1 主机资源指标

| 指标 | 采样间隔 | WARN 阈值 | CRITICAL 阈值 |
|------|----------|-----------|--------------|
| CPU 使用率 | 15s | > 70% (持续 5min) | > 90% (持续 2min) |
| 内存使用率 | 15s | > 75% | > 90% |
| 磁盘使用率 | 60s | > 80% | > 95% |
| 磁盘 I/O 等待 | 15s | avg > 10ms | avg > 50ms |
| 网络入流量 | 15s | > 带宽 70% | > 带宽 90% |
| 网络出流量 | 15s | > 带宽 70% | > 带宽 90% |
| 负载均衡 (1m/5m/15m) | 60s | > 2.0 | > 5.0 |
| 进程存活数 | 30s | < 期望数 | 0 |

### 2.2 Docker / K8s 特定指标

| 指标 | 来源 | 告警条件 |
|------|------|----------|
| Container OOMKilled | K8s events | 任意容器 OOM 即告警 |
| CrashLoopBackOff | K8s events | 重启 > 3 次/10min |
| Pod Pending > 5min | K8s scheduler | 资源不足 |
| ImagePullBackOff | K8s kubelet | 镜像拉取失败 |
| Restart Count | Docker/K8s | > 5次/hour |
| Replica 偏差 | K8s Deployment | current ≠ desired 超 1min |

---

## 三、业务层监控

### 3.1 核心 North Star Metrics

| 指标名 | 定义 | 计算方式 | 正常基准 |
|--------|------|----------|----------|
| ** availability** | 服务可用率 | 成功请求数 / 总请求数 | ≥ 99.9% |
| **error_rate** | 错误率 | 5xx 请求数 / 总请求数 | < 0.1% |
| **latency_p50** | 中位延迟 | 第 50 百分位响应时间 | < 200ms |
| **latency_p99** | 尾巴延迟 | 第 99 百分位响应时间 | < 1s |
| **throughput** | 吞吐量 | requests/second | 按业务定义 |

### 3.2 业务特定指标（按需扩展）

| 类别 | 示例指标 | 告警场景 |
|------|----------|----------|
| 用户 | DAU/MAU、注册转化率 | 日活跌超 30% |
| 交易 | 订单量、支付成功率 | 支付成功率 < 95% |
| 内容 | 发布量、互动率 | 发布量突降为 0 |
| 搜索 | 搜索量、零结果率 | 零结果率 > 20% |

---

## 四、告警规则

### 4.1 告警分级

| 等级 | 名称 | 通知渠道 | 响应时间(SLA) | 示例场景 |
|------|------|----------|---------------|----------|
| **P0** | Critical | 电话 + 短信 + IM 全员 | < 5 min | 服务宕机、数据丢失风险 |
| **P1** | Warning | 电话 + IM | < 15 min | 错误率飙升、性能严重退化 |
| **P2** | Notice | IM + 邮件 | < 2 h | 单实例重启、磁盘空间紧张 |
| **P3** | Info | 邮件 | 下工作日 | 证书即将到期、非核心依赖降级 |

### 4.2 告警抑制与静默

避免告警风暴的规则：
- **同一告警**：10 分钟内不重复发送
- **关联告警**：DB 连接失败 → 抑制 DB 相关的所有子告警
- **维护窗口**：预定的发布/运维期间自动静默非 P0 告警
- **自动恢复**：问题解决后发送 resolved 通知

### 4.3 常用告警规则（Prometheus Rule 格式）

```yaml
# alerts.yml — WebHarness 告警规则
groups:
  - name: webapp-critical
    rules:
      # 服务不可用
      - alert: ServiceDown
        expr: up{job="webapp"} == 0
        for: 30s
        labels:
          severity: critical
        annotations:
          summary: "WebApp 服务 {{ $labels.instance }} 宕机"
          description: "服务已停机超过 30 秒，立即检查！"

      # 错误率飙升
      - alert: HighErrorRate
        expr: |
          sum(rate(http_requests_total{status=~"5.."}[5m]))
          /
          sum(rate(http_requests_total[5m])) > 0.05
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "错误率超过 5%"
          description: "当前错误率: {{ $value | humanizePercentage }}"

      # P99 延迟过高
      - alert: HighLatency
        expr: |
          histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m])) > 3
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "P99 延迟超过 3s"
          description: "当前 P99: {{ $value }}s"

      # 内存压力
      - alert: HighMemoryUsage
        expr: process_resident_memory_bytes / 1024 / 1024 > 800
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "内存使用超过 800MB"
          description: "当前: {{ $value }}MB"

      # 磁盘空间不足
      - alert: DiskSpaceLow
        expr: (1 - node_filesystem_avail_bytes / node_filesystem_size_bytes) * count(node_filesystem_mountpoint="/") > 0.85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "磁盘使用率超过 85%"
          description: "剩余空间不足，请注意清理"

  - name: webapp-business
    rules:
      # 转化率异常下降
      - alert: ConversionRateDrop
        expr: |
          conversion_rate
          /
          offset(1w, conversion_rate) < 0.7
        for: 1h
        labels:
          severity: notice
        annotations:
          summary: "转化率相比上周下降超过 30%"
          description: "当前转化率: {{ $value }}"
```

---

## 五、Dashboard 模板

### 5.1 核心监控面板（Grafana JSON 参考）

面板布局（推荐 4 行 × 3 列）：

```
┌─────────────────────┬─────────────────────┬─────────────────────┐
│  请求总量(RPS)       │  错误率 (%)         │  平均延迟 (ms)       │
│  [TimeSeries Chart]  │  [TimeSeries Chart]  │  [TimeSeries Chart]  │
├─────────────────────┼─────────────────────┼─────────────────────┤
│  P50/P95/P99 延迟    │  HTTP 状态码分布      │  Top 5 慢接口        │
│  [Heatmap]           │  [Pie Chart]        │  [Table]            │
├─────────────────────┼─────────────────────┼─────────────────────┤
│  CPU / Mem 使用率    │  数据库连接池        │  Redis 命中率        │
│  [Gauge + Chart]    │  [Gauge]            │  [Gauge]            │
├─────────────────────┴─────────────────────┴─────────────────────┤
│  最近告警事件 (Alert Table)                                       │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Dashboard 必备面板清单

| 序号 | 面板名 | 图表类型 | 数据源 | 刷新频率 |
|------|--------|----------|--------|----------|
| 1 | 请求 RPS | TimeSeries | Prometheus | 15s |
| 2 | 错误率 | TimeSeries | Prometheus | 15s |
| 3 | P50/P95/P99 | Heatmap | Prometheus | 15s |
| 4 | HTTP Status 分布 | Pie | Prometheus | 30s |
| 5 | Top N 慢请求 | Table | Prometheus (topk) | 30s |
| 6 | CPU/Memory | Gauge + TS | node_exporter | 15s |
| 7 | DB 连接池 | Gauge | db exporter | 15s |
| 8 | Cache 命中率 | Gauge | redis exporter | 30s |
| 9 | 活跃用户数 | Stat (Counter) | 自定义 | 60s |
| 10 | 告警事件列表 | Alert List | AlertManager | 30s |

---

## 六、健康检查脚本

`scripts/health-check.sh` 提供 CLI 方式的快速健康诊断：

```bash
#!/bin/bash
# WebHarness Health Check Script
# Usage: ./scripts/health-check.sh [env]
# env: dev (default) | staging | prod

ENV=${1:-dev}
BASE_URL=$(get_env_url "$ENV")
PASS=0
FAIL=0
WARN=0

echo "=== WebHarness Health Check ==="
echo "Environment: $ENV"
echo "Target: $BASE_URL"
echo "Time: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo ""

# 1. Liveness
check "Liveness" "$BASE_URL/api/health/live" 10

# 2. Readiness (含依赖)
check "Readiness" "$BASE_URL/api/health/ready" 100

# 3. 核心端点Smoke Test
check_endpoint "GET /api/users" "$BASE_URL/api/users" 200 500
check_endpoint "POST /api/auth/login" "$BASE_URL/api/auth/login" 200 1000
check_endpoint "GET /api/health/full" "$BASE_URL/api/health/full" 200 500

# 4. SSL 证书 (prod only)
if [ "$ENV" = "prod" ]; then
  check_ssl "$(extract_host "$BASE_URL")" 30
fi

# 结果汇总
echo ""
echo "==========================="
echo "✅ PASS: $PASS  ⚠️ WARN: $WARN  ❌ FAIL: $FAIL"
echo "==========================="

if [ $FAIL -gt 0 ]; then
  exit 2  # CRITICAL
elif [ $WARN -gt 0 ]; then
  exit 1  # WARNING
else
  exit 0  # HEALTHY
fi
```

---

## 七、On-Call 响应流程

```
告警触发
    ↓
P0/P1 → 电话+IM  → On-Call 接收 → 5min 内 Ack
    ↓
初步判断（查看 Dashboard + 日志）
    ↓
┌─────────────┬────────────────┬──────────────┐
│ 已知问题     │ 需要排查        │ 误报          │
│ 按Runbook处理 │ 15min内定位原因 │ 关闭告警+优化规则│
└─────────────┴────────────────┴──────────────┘
    ↓
执行修复 / 回滚 / 临时规避
    ↓
验证恢复（Health Check 全绿）
    ↓
写 Post-Mortem（P0 必须，P1 建议）
```
