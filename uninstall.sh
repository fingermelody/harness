#!/bin/bash
#
# Harness 卸载脚本
# 从目标项目中移除 WebHarness 多智能体协作框架
#
# 用法:
#   ./uninstall.sh [目标目录]     # 从指定目录卸载
#   ./uninstall.sh               # 从当前目录卸载
#   ./uninstall.sh --user         # 卸载全局技能 (~/.workbuddy/)
#   ./uninstall.sh --force        # 无需确认直接删除
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
FORCE_DELETE=false

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --user)
            INSTALL_MODE="user"
            shift
            ;;
        --force)
            FORCE_DELETE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [目标目录] [--user] [--force] [--help]"
            echo ""
            echo "选项:"
            echo "  --user      卸载全局技能 (~/.workbuddy/)"
            echo "  --force     无需确认直接删除"
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
if [ "$INSTALL_MODE" = "user" ]; then
    TARGET_DIR="$HOME/.workbuddy"
elif [ -z "$TARGET_DIR" ]; then
    TARGET_DIR="$(pwd)"
fi

# 规范化路径
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  WebHarness 卸载脚本${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

echo -e "${GREEN}目标目录:${NC} $TARGET_DIR"
echo -e "${GREEN}卸载模式:${NC} $INSTALL_MODE"
echo ""

# 检查是否存在 harness 文件
if [ ! -d "$TARGET_DIR/rules" ] && [ ! -d "$TARGET_DIR/agents" ]; then
    echo -e "${YELLOW}警告: 目标目录中未找到 Harness 安装痕迹${NC}"
    echo "以下目录不存在: rules/, agents/"
    echo ""
    read -p "是否仍要删除 .workbuddy 目录? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "卸载已取消"
        exit 0
    fi
fi

# 确认删除
if [ "$FORCE_DELETE" = false ]; then
    echo -e "${RED}警告: 即将删除以下内容:${NC}"
    echo ""
    echo "  ├── rules/              # 规则与规范"
    echo "  ├── agents/             # Agent 角色定义"
    echo "  ├── evals/              # 评估体系"
    echo "  ├── memory/             # 记忆系统"
    echo "  ├── docs/               # 文档模板"
    echo "  ├── scripts/            # 自动化脚本"
    echo "  ├── hooks/              # Git 钩子"
    echo "  ├── skills/             # 技能包"
    echo "  ├── tests/              # 测试基础设施"
    echo "  ├── .workbuddy/         # 工作记忆"
    echo "  └── README.md           # 项目说明（如由 Harness 生成）"
    echo ""
    echo -e "${RED}此操作不可撤销!${NC}"
    echo ""
    read -p "确定要继续? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "卸载已取消"
        exit 0
    fi
fi

echo ""
echo -e "${BLUE}开始卸载...${NC}"
echo ""

# 函数：删除目录或文件
remove_item() {
    local path="$1"
    local item_name=$(basename "$path")

    if [ ! -e "$path" ]; then
        return
    fi

    rm -rf "$path"
    echo -e "${GREEN}✓ 删除:${NC} $item_name"
}

# 1. 删除规则与规范
if [ -d "$TARGET_DIR/rules" ]; then
    echo -e "${BLUE}[1/10] 删除规则与规范...${NC}"
    remove_item "$TARGET_DIR/rules"
fi

# 2. 删除 Agent 角色定义
if [ -d "$TARGET_DIR/agents" ]; then
    echo -e "${BLUE}[2/10] 删除 Agent 角色定义...${NC}"
    remove_item "$TARGET_DIR/agents"
fi

# 3. 删除评估体系
if [ -d "$TARGET_DIR/evals" ]; then
    echo -e "${BLUE}[3/10] 删除评估体系...${NC}"
    remove_item "$TARGET_DIR/evals"
fi

# 4. 删除记忆系统
if [ -d "$TARGET_DIR/memory" ]; then
    echo -e "${BLUE}[4/10] 删除记忆系统...${NC}"
    remove_item "$TARGET_DIR/memory"
fi

# 5. 删除文档模板
if [ -d "$TARGET_DIR/docs" ]; then
    echo -e "${BLUE}[5/10] 删除文档模板...${NC}"
    remove_item "$TARGET_DIR/docs"
fi

# 6. 删除自动化脚本
if [ -d "$TARGET_DIR/scripts" ]; then
    echo -e "${BLUE}[6/10] 删除自动化脚本...${NC}"
    remove_item "$TARGET_DIR/scripts"
fi

# 7. 删除 Git 钩子
if [ -d "$TARGET_DIR/hooks" ]; then
    echo -e "${BLUE}[7/10] 删除 Git 钩子...${NC}"
    remove_item "$TARGET_DIR/hooks"
fi

# 8. 删除技能包
if [ -d "$TARGET_DIR/skills" ] && [ "$INSTALL_MODE" != "user" ]; then
    echo -e "${BLUE}[8/10] 删除技能包...${NC}"
    remove_item "$TARGET_DIR/skills"
fi

# 9. 删除测试基础设施
if [ -d "$TARGET_DIR/tests" ]; then
    echo -e "${BLUE}[9/10] 删除测试基础设施...${NC}"
    remove_item "$TARGET_DIR/tests"
fi

# 10. 删除配置文件
echo -e "${BLUE}[10/10] 删除配置文件...${NC}"
for file in vitest.config.ts package.json README.md .gitignore; do
    if [ -f "$TARGET_DIR/$file" ]; then
        # 检查是否是 Harness 生成的文件
        if grep -q "WebHarness\|harness" "$TARGET_DIR/$file" 2>/dev/null; then
            remove_item "$TARGET_DIR/$file"
        fi
    fi
done

# 删除 .workbuddy 目录
if [ -d "$TARGET_DIR/.workbuddy" ]; then
    echo ""
    echo -e "${YELLOW}删除 .workbuddy 目录...${NC}"
    remove_item "$TARGET_DIR/.workbuddy"
fi

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  卸载完成!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "目标目录: ${BLUE}$TARGET_DIR${NC}"
echo ""
echo "注意:"
echo "  - Git 历史记录未删除（如需完全删除，请手动删除 .git 目录）"
echo "  - 如果是 --user 模式，全局技能已从 ~/.workbuddy/ 移除"
echo ""