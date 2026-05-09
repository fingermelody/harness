#!/bin/bash
# WebHarness Environment Setup Script

set -e

echo "🚀 WebHarness 环境初始化"

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未安装"
    exit 1
fi

echo "✅ Node.js $(node -v)"

# 安装依赖
if [ -f "package.json" ]; then
    echo "📦 安装依赖..."
    npm install
else
    echo "⚠️  未找到 package.json"
fi

# 检查 git hooks
echo "🪝 检查 Git Hooks..."
if [ -d ".git" ]; then
    chmod +x hooks/*
    echo "✅ Hooks 已配置"
fi

# 创建必要目录
echo "📁 创建工作目录..."
mkdir -p memory/backups evals/reports logs

echo ""
echo "✅ 环境初始化完成！"
echo ""
echo "可用命令："
echo "  npm run dev      - 启动开发服务器"
echo "  npm run build    - 构建项目"
echo "  npm run test     - 运行测试"
echo "  npm run lint     - 代码检查"