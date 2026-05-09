#!/bin/bash
# WebHarness Health Check

echo "🔍 WebHarness 健康检查"
echo "========================"

# 检查依赖
echo -n "Node.js: "
if node -e "process.exit(0)" 2>/dev/null; then
    echo "✅ $(node -v)"
else
    echo "❌ 未安装"
fi

echo -n "npm: "
if npm -v &>/dev/null; then
    echo "✅ $(npm -v)"
else
    echo "❌ 未安装"
fi

# 检查关键文件
echo ""
echo "📁 检查关键文件..."
for file in package.json vitest.config.ts tsconfig.json; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file"
    fi
done

# 检查目录
echo ""
echo "📂 检查目录结构..."
dirs=("src" "harness" "tests" "skills" "docs" "rules" "memory" "evals" "scripts" "hooks")
for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "  ✅ $dir/"
    else
        echo "  ⚠️  $dir/ (未创建)"
    fi
done

echo ""
echo "========================"
echo "✅ 健康检查完成"