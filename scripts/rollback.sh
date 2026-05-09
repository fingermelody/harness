#!/bin/bash
# WebHarness Rollback Script

set -e

echo "🔄 WebHarness 回滚"
echo "========================"

BACKUP_DIR=${1:-""}

if [ -z "$BACKUP_DIR" ]; then
    echo "📋 可用备份:"
    ls -la backups/ 2>/dev/null || echo "  无备份"
    echo ""
    read -p "输入备份目录: " BACKUP_DIR
fi

if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ 备份不存在: $BACKUP_DIR"
    exit 1
fi

# 确认
echo ""
echo "⚠️  即将回滚到: $BACKUP_DIR"
read -p "确认? (y/N): " confirm

if [ "$confirm" != "y" ]; then
    echo "取消回滚"
    exit 0
fi

# 执行回滚
echo "🔄 执行回滚..."
rm -rf dist/
cp -r "$BACKUP_DIR/dist" ./

echo ""
echo "========================"
echo "✅ 回滚完成"
echo "📁 当前版本: $(ls -la dist/ | head -2 | tail -1)"