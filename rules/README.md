# 规则与规范

本目录包含 WebHarness 项目的所有规则定义：**代码规范** + **Agent 行为规范**。

## 文件结构

```
rules/
├── .eslintrc.json      # ESLint 代码检查配置
├── .prettierrc.json   # Prettier 代码格式化配置
├── .prettierignore    # Prettier 忽略文件
├── tsconfig.json      # TypeScript 主配置（严格模式）
├── tsconfig.test.json # TypeScript 测试配置
├── agent-dispatch.md  # ⭐ Agent 分派规则（核心行为约束）
└── README.md          # 本文件
```

## 使用方法

### ESLint

```bash
# 检查代码
npm run lint

# 自动修复
npm run lint:fix
```

### Prettier

```bash
# 格式化所有文件
npm run format

# 检查格式
npm run format:check
```

### TypeScript

```bash
# 类型检查
npm run typecheck

# 编译
npm run build
```

## 集成

- **Git Hooks**: `hooks/pre-commit` 自动运行 lint 和 format
- **CI/CD**: 脚本在部署前执行类型检查和 lint

## 规则说明

### ESLint 规则

- `no-console`: 生产环境禁止 console.log
- `prefer-const`: 优先使用 const
- `no-unused-vars`: 禁止未使用的变量

### TypeScript 严格模式

启用了完整的严格类型检查，包括：
- `strictNullChecks`: null/undefined 检查
- `noImplicitAny`: 禁止隐式 any
- `noUnusedLocals`: 禁止未使用的局部变量

### Prettier 配置

- 单引号字符串
- 行尾分号
- 100 字符行宽
- Unix 风格换行符

---

## Agent 行为规范

### ⭐ 核心规则：主 Agent 只分派，不执行

详见 **[agent-dispatch.md](./agent-dispatch.md)**。

**一句话总结**：主 Agent（Team Lead）是"指挥官"，负责任务拆解、角色分配、进度追踪和质量把关。所有具体的代码编写、测试、部署、文档产出等操作，必须分派给对应角色的子 Agent 执行。