# WebHarness Scripts
# 自动化脚本目录

## 脚本列表

| 脚本 | 说明 |
|------|------|
| `setup.sh` | 环境初始化 |
| `health-check.sh` | 健康检查 |
| `deploy-test.sh` | 测试环境部署 |
| `deploy-prod.sh` | 生产环境部署 |
| `rollback.sh` | 版本回滚 |
| `run-eval.sh` | 运行评估 |

## 使用方法

```bash
# 初始化环境
./scripts/setup.sh

# 健康检查
./scripts/health-check.sh

# 部署
./scripts/deploy-test.sh
./scripts/deploy-prod.sh v1.0.0

# 回滚
./scripts/rollback.sh backups/v1.0.0

# 评估
./scripts/run-eval.sh
```

## 权限

首次使用需要添加执行权限:
```bash
chmod +x scripts/*.sh scripts/*.js
```