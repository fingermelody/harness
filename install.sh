#!/bin/bash
#
# Harness 安装脚本
# 将 WebHarness 多智能体协作框架安装到目标项目中
#
# 用法:
#   ./install.sh [目标目录]     # 安装到指定目录
#   ./install.sh               # 安装到当前目录
#   ./install.sh --user         # 安装到 ~/.codebuddy/（全局）
#   ./install.sh --force        # 覆盖已有文件
#

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认值
TARGET_DIR=""
INSTALL_MODE="project"  # project | user
FORCE_OVERWRITE=false
HARNESS_SOURCE="$(cd "$(dirname "$0")" && pwd)"

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --user)
            INSTALL_MODE="user"
            shift
            ;;
        --force)
            FORCE_OVERWRITE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [目标目录] [--user] [--force] [--help]"
            echo ""
            echo "选项:"
            echo "  --user      安装到 ~/.codebuddy/（全局可用）"
            echo "  --force     覆盖已有文件"
            echo "  -h, --help  显示帮助信息"
            exit 0
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

# 确定目标目录
# 项目级：安装到 目标项目/.codebuddy/
# 用户级：安装到 ~/.codebuddy/
if [ "$INSTALL_MODE" = "user" ]; then
    TARGET_DIR="$HOME"
elif [ -z "$TARGET_DIR" ]; then
    TARGET_DIR="$(pwd)"
fi

# 规范化路径
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# 安装目标统一为 .codebuddy/
DEST_DIR="$TARGET_DIR/.codebuddy"

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  WebHarness 安装脚本${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# 检查源目录
if [ ! -d "$HARNESS_SOURCE/rules" ] || [ ! -f "$HARNESS_SOURCE/skills/web-harness/SKILL.md" ]; then
    echo -e "${RED}错误: 无法找到 Harness 源文件${NC}"
    echo "请确保在 harness 项目根目录运行此脚本"
    exit 1
fi

echo -e "${GREEN}源目录:${NC} $HARNESS_SOURCE"
echo -e "${GREEN}项目目录:${NC} $TARGET_DIR"
echo -e "${GREEN}安装目标:${NC} $DEST_DIR"
echo -e "${GREEN}安装模式:${NC} $INSTALL_MODE"
echo ""

# 函数：复制文件或目录
copy_item() {
    local src="$1"
    local dest="$2"
    local item_name=$(basename "$src")

    if [ ! -e "$src" ]; then
        echo -e "${YELLOW}跳过 (不存在):${NC} $item_name"
        return
    fi

    # 检查是否已存在
    if [ -e "$dest" ] && [ "$FORCE_OVERWRITE" = false ]; then
        echo -e "${YELLOW}跳过 (已存在):${NC} $item_name"
        return
    fi

    # 创建父目录
    mkdir -p "$(dirname "$dest")"

    # 复制
    if [ -d "$src" ]; then
        cp -r "$src" "$dest"
    else
        cp "$src" "$dest"
    fi
    echo -e "${GREEN}✓ 安装:${NC} $item_name"
}

# 确认安装
echo -e "${YELLOW}即将安装以下内容到 ${DEST_DIR}:${NC}"
echo ""
echo "  ├── rules/              # 规则与规范"
echo "  ├── agents/              # Agent 角色定义"
echo "  ├── evals/               # 评估体系"
echo "  ├── memory/              # 记忆系统"
echo "  ├── teams/               # 团队配置（项目级）"
echo "  ├── docs/                # 文档模板"
echo "  ├── scripts/             # 自动化脚本"
echo "  ├── hooks/               # Git 钩子"
echo "  ├── skills/              # 技能包"
echo "  └── src/                 # 框架源代码"
echo ""
echo -e "${YELLOW}注意: 文件将写入 .codebuddy/ 目录${NC}"
echo ""

read -p "继续安装? [y/N] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "安装已取消"
    exit 0
fi

echo ""
echo -e "${BLUE}开始安装...${NC}"
echo ""

# 1. 复制规则与规范
echo -e "${BLUE}[1/8] 复制规则与规范...${NC}"
for item in rules; do
    copy_item "$HARNESS_SOURCE/$item" "$DEST_DIR/$item"
done

# 2. 复制 Agent 角色定义
echo -e "${BLUE}[2/8] 复制 Agent 角色定义...${NC}"
for item in agents; do
    copy_item "$HARNESS_SOURCE/$item" "$DEST_DIR/$item"
done

# 3. 复制评估体系
echo -e "${BLUE}[3/8] 复制评估体系...${NC}"
for item in evals; do
    copy_item "$HARNESS_SOURCE/$item" "$DEST_DIR/$item"
done

# 4. 复制记忆系统
echo -e "${BLUE}[4/8] 复制记忆系统...${NC}"
for item in memory; do
    copy_item "$HARNESS_SOURCE/$item" "$DEST_DIR/$item"
done

# 5. 复制文档模板
echo -e "${BLUE}[5/8] 复制文档模板...${NC}"
for item in docs; do
    copy_item "$HARNESS_SOURCE/$item" "$DEST_DIR/$item"
done

# 6. 复制自动化脚本
echo -e "${BLUE}[6/8] 复制自动化脚本...${NC}"
for item in scripts; do
    copy_item "$HARNESS_SOURCE/$item" "$DEST_DIR/$item"
done

# 7. 复制技能包
echo -e "${BLUE}[7/9] 复制技能包...${NC}"
for item in skills; do
    copy_item "$HARNESS_SOURCE/$item" "$DEST_DIR/$item"
done

# 8. 复制 Git 钩子
echo -e "${BLUE}[8/9] 复制 Git 钩子...${NC}"
for item in hooks; do
    copy_item "$HARNESS_SOURCE/$item" "$DEST_DIR/$item"
done

# 9. 复制测试基础设施
echo -e "${BLUE}[9/9] 复制测试基础设施...${NC}"
for item in tests vitest.config.ts package.json; do
    if [ -e "$HARNESS_SOURCE/$item" ]; then
        copy_item "$HARNESS_SOURCE/$item" "$DEST_DIR/$item"
    fi
done

# 创建 .codebuddy/memory 目录（用于项目级记忆）
echo ""
echo -e "${BLUE}创建项目级目录...${NC}"
mkdir -p "$DEST_DIR/memory"
mkdir -p "$DEST_DIR/teams"

# 10. 复制 codebuddy.md 到项目根目录
echo -e "${BLUE}[10/10] 复制 codebuddy.md 到项目根目录...${NC}"
if [ -f "$HARNESS_SOURCE/codebuddy.md" ]; then
    if [ -e "$TARGET_DIR/codebuddy.md" ] && [ "$FORCE_OVERWRITE" = false ]; then
        echo -e "${YELLOW}跳过 (已存在):${NC} codebuddy.md"
    else
        cp "$HARNESS_SOURCE/codebuddy.md" "$TARGET_DIR/codebuddy.md"
        echo -e "${GREEN}✓ 安装:${NC} codebuddy.md → $TARGET_DIR/"
    fi
else
    echo -e "${YELLOW}跳过 (不存在):${NC} codebuddy.md"
fi

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  安装完成!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "安装目标: ${BLUE}$DEST_DIR${NC}"
echo ""
echo "下一步:"
echo "  1. 在 CodeBuddy 中打开目标项目"
echo "  2. 使用 /web-harness 初始化新项目"
echo ""