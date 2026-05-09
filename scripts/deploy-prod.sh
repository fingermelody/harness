#!/bin/bash
# WebHarness Production Deployment

set -e

echo "🚀 WebHarness 生产环境部署"
echo "========================"

VERSION=${1:-$(date +%Y%m%d-%H%M%S)}

# 前置检查
echo "📋 前置检查..."
if [ ! -f "package.json" ]; then
    echo "❌ 未找到 package.json"
    exit 1
fi

# 代码检查
echo "🔍 代码检查..."
npm run lint
npm run typecheck

# 测试
echo "🧪 运行测试..."
npm run test

# 构建
echo "🏗️  构建生产版本..."
npm run build

# 备份
echo "💾 备份当前版本..."
BACKUP_DIR="backups/v$VERSION"
mkdir -p "$BACKUP_DIR"
cp -r dist "$BACKUP_DIR/"

echo ""
echo "========================"
echo "✅ 生产环境部署完成"
echo "📦 版本: $VERSION"
echo "📁 备份: $BACKUP_DIR"
echo ""
echo "下一步: 使用 smoke-test.sh 验证部署"