---
name: to-prd
description: 将当前对话上下文转化为 PRD，并自动发布到腾讯 TAPD。当用户想要创建 PRD、写需求文档、发布 PRD 到 TAPD 时使用。
agent_created: true
---

将当前对话上下文和代码库理解转化为 PRD，并自动发布到腾讯 TAPD 项目管理系统。

## 整体流程

```
Phase 1: 分析 → 生成 PRD 文档
Phase 2: 发现 TAPD 项目 → 确认目标
Phase 3: 创建 TAPD 需求树 → 关联迭代 → 生成 Wiki
```

---

## Phase 1: 分析与生成 PRD

1. **探索代码库**：理解当前代码库状态，使用项目的领域术语表词汇，遵守相关 ADR。如果尚未探索过，先用 Explore agent 扫描项目结构。

2. **梳理模块**：列出需要构建或修改的主要模块。主动寻找可以独立测试的深模块（deep module）。

   > 深模块 = 封装大量功能、接口简洁、变更频率低的模块

3. **与用户确认模块范围**：确认模块划分是否符合预期，确认哪些模块需要写测试。

4. **生成 PRD 文档**：使用下方模板生成 PRD。

---

## Phase 2: 发现 TAPD 项目

PRD 生成后，自动对接 TAPD：

1. **获取用户 TAPD 项目列表**：调用 `user_participant_workspace_get`（无需参数），获取用户参与的所有项目。

2. **确认目标项目**：
   - 如果用户已指定项目名或 workspace_id → 直接使用
   - 如果项目上下文中有明确线索（如 git remote、项目名匹配）→ 推荐匹配项
   - 否则 → 列出项目列表让用户选择（AskUserQuestion）

3. **验证项目**：调用 `workspace_get` 确认 workspace_id 有效性。

4. **获取迭代和分类信息**（可选）：
   - 调用 `iterations_get` 获取当前/未关闭迭代，供后续关联
   - 调用 `story_category_get` 获取需求分类，供用户选择

---

## Phase 3: 创建 TAPD 需求树

### 3.1 创建 PRD 父需求

调用 `stories_create` 创建父需求：

```
workspace_id = <Phase 2 获取的项目 ID>
name = "[PRD] <PRD 标题>"
description = <Phase 1 生成的完整 PRD Markdown 内容>
priority_label = "High"
category_id = <用户选择的分类，可选>
iteration_id = <用户选择的迭代，可选>
label = "PRD"
```

### 3.2 解析 User Stories 并创建子需求

从 PRD 的 User Stories 部分解析每一条用户故事，逐一调用 `stories_create` 创建子需求：

```
workspace_id = <项目 ID>
parent_id = <3.1 创建的父需求 ID>
name = "作为 <actor>，我想要 <feature>，以便 <benefit>"
description = <该用户故事的详细描述，从 PRD 中提取相关上下文>
priority_label = "Middle"  # 默认，可让用户调整
iteration_id = <用户选择的迭代，可选>
```

### 3.3 创建实现任务（可选）

如果 PRD 的 Implementation Decisions 部分有明确的开发任务，调用 `tasks_create` 为每个任务创建 TAPD 任务：

```
workspace_id = <项目 ID>
name = <任务标题>
description = <任务详细描述>
story_id = <3.1 创建的父需求 ID>
owner = <指定开发者，可选>
priority_label = "Medium"
```

### 3.4 创建 Wiki 页面（推荐）

调用 `wikis_create` 创建 PRD Wiki 页面，方便团队在线查阅完整 PRD：

```
workspace_id = <项目 ID>
name = "[PRD] <PRD 标题>"
markdown_description = <Phase 1 生成的完整 PRD Markdown 内容>
```

---

## PRD 模板

```markdown
## 问题陈述 (Problem Statement)

用户面临的问题，从用户视角描述。

## 解决方案 (Solution)

问题的解决方案，从用户视角描述。

## 用户故事 (User Stories)

一个详细的、带编号的用户故事列表。每条用户故事格式：

1. 作为 <actor>，我想要 <feature>，以便 <benefit>

> ⚠️ 每条用户故事将自动创建为 TAPD 子需求，请确保：
> - 每条故事独立完整，有明确的验收标准
> - 故事粒度适中（不过大也不过小）
> - 包含足够的上下文信息

## 实现决策 (Implementation Decisions)

实现决策列表，包括：

- 需要构建/修改的模块
- 模块接口的变更
- 开发者的技术澄清
- 架构决策
- Schema 变更
- API 契约
- 具体交互逻辑

不要包含具体的文件路径或代码片段（容易过时）。

例外：如果原型产出的代码片段能比文字更精确地编码决策（状态机、reducer、schema、类型形状），可内联在相关决策中，标注来自原型。只保留决策关键部分——不是可运行的 demo，而是重要的决策点。

## 测试决策 (Testing Decisions)

测试决策列表，包括：

- 好的测试标准（只测外部行为，不测实现细节）
- 需要测试的模块
- 代码库中的先例（类似测试）

## 范围外 (Out of Scope)

PRD 范围外的内容描述。

## 补充说明 (Further Notes)

关于该功能的任何补充说明。
```

---

## TAPD 工具调用参考

本技能使用以下 TAPD MCP 工具（`mcp__tapd-woa` 前缀）：

| 步骤 | 工具 | 用途 |
|------|------|------|
| 获取项目列表 | `user_participant_workspace_get` | 无参数，自动识别当前用户 |
| 验证项目 | `workspace_get` | 确认 workspace_id 有效 |
| 获取迭代 | `iterations_get` | 查询当前/未关闭迭代 |
| 获取分类 | `story_category_get` | 查询需求分类列表 |
| 创建父需求 | `stories_create` | workspace_id + name 必填 |
| 创建子需求 | `stories_create` | 需额外传 parent_id |
| 创建任务 | `tasks_create` | 关联 story_id |
| 创建 Wiki | `wikis_create` | 支持 markdown_description |
| ID 转换 | `tapd_id_get` | 短 ID → 19 位长 ID |

### 工具调用规范

1. **先查 schema**：首次调用任何 TAPD 工具前，先调用 `lookup_tool_param_schema` 获取参数定义
2. **使用 proxy 执行**：所有 TAPD 工具通过 `proxy_execute_tool` 执行，传入 tool_name 和 tool_args
3. **ID 格式**：TAPD 长ID为19位字符串；若只有短ID，先调用 `tapd_id_get` 转换
4. **description 字段**：支持 Markdown 格式，PRD 内容直接填入

### 错误处理

- workspace_id 无效 → 重新获取项目列表让用户选择
- stories_create 失败 → 检查必填字段（workspace_id、name），重试一次
- parent_id 格式错误 → 调用 tapd_id_get 转换后重试
- 网络超时 → 提示用户检查 TAPD MCP 连接状态

---

## 使用示例

```
用户: "帮我写一个用户登录模块的 PRD 并发到 TAPD"
→ Phase 1: 分析代码库 → 生成 PRD
→ Phase 2: 获取 TAPD 项目列表 → 用户选择目标项目
→ Phase 3: 创建父需求 [PRD] 用户登录模块
         → 创建子需求（每条用户故事一个）
         → 创建 Wiki 页面
         → 输出所有创建的 TAPD 链接

用户: "把这个需求文档同步到 TAPD 的 XX 项目"
→ 跳过 Phase 1（PRD 已有）
→ Phase 2: 匹配 XX 项目
→ Phase 3: 创建需求树
```
