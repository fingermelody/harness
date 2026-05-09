#!/bin/bash
# WebHarness Git Hooks Installation Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GIT_DIR="$(git rev-parse --git-dir 2>/dev/null || echo "")"

if [ -z "$GIT_DIR" ]; then
    echo "❌ Not a git repository"
    exit 1
fi

HOOKS_DIR="$GIT_DIR/hooks"

echo "🪝 Installing WebHarness Git Hooks..."
echo "   Source: $SCRIPT_DIR"
echo "   Target: $HOOKS_DIR"

# 复制 hooks
for hook in pre-commit commit-msg pre-push post-checkout; do
    if [ -f "$SCRIPT_DIR/$hook" ]; then
        cp "$SCRIPT_DIR/$hook" "$HOOKS_DIR/$hook"
        chmod +x "$HOOKS_DIR/$hook"
        echo "  ✅ $hook"
    fi
done

echo ""
echo "✅ Git hooks installed successfully!"
echo ""
echo "Available hooks:"
echo "  pre-commit   - 代码检查 & 测试"
echo "  commit-msg   - 提交信息格式验证"
echo "  pre-push     - 推送前完整检查"
echo "  post-checkout - 分支切换处理"