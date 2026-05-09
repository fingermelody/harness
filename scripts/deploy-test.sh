#!/bin/bash
# WebHarness Test Environment Deployment

set -e

echo "🚀 WebHarness 测试环境部署"
echo "========================"

# 环境检查
echo "📋 检查环境..."
if [ ! -f "package.json" ]; then
    echo "❌ 未找到 package.json"
    exit 1
fi

# 清理
echo "🧹 清理旧构建..."
rm -rf dist/

# 安装依赖
echo "📦 安装依赖..."
npm install

# 类型检查
echo "🔍 TypeScript 类型检查..."
npx tsc --noEmit

# 运行测试
echo "🧪 运行测试..."
npm test

# 构建
echo "🏗️  构建项目..."
npm run build

echo ""
echo "========================"
echo "✅ 测试环境部署完成"
echo "📦 构建产物: dist/"