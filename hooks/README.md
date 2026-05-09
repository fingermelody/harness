# WebHarness Git Hooks
# 自动化 Git 钩子配置

## 钩子列表

| 钩子 | 触发时机 | 功能 |
|------|----------|------|
| `pre-commit` | `git commit` | 代码检查、敏感信息检测、测试 |
| `commit-msg` | `git commit -m` | 提交信息格式验证 |
| `pre-push` | `git push` | 完整测试 + 构建验证 |
| `post-checkout` | `git checkout` | 分支切换后依赖检查 |

## 安装

```bash
# 自动安装
./hooks/install.sh

# 或手动链接
ln -s ../../hooks/pre-commit .git/hooks/
```

## 跳过钩子

```bash
# 跳过 pre-commit
git commit --no-verify -m "WIP: workaround"

# 跳过 pre-push
git push --no-verify
```

## 自定义

修改各钩子文件以调整检查规则:
- `pre-commit`: 添加更多检查规则
- `commit-msg`: 修改格式要求
- `pre-push`: 添加更多验证步骤

## 安全说明

- 敏感信息检测基于正则匹配，可能有误报
- 生产环境应使用专用 CI/CD 验证
- 不要在钩子中执行破坏性操作