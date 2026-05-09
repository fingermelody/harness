# WebHarness 文档中心

本目录存储 WebHarness 框架的所有项目文档。

## 目录结构

```
docs/
├── STATE-MACHINE.md        # 状态机工作流（核心文档）
├── README.md               # 本文件
├── specs/                  # 功能规格说明书 (Spec)
│   └── SPEC-TEMPLATE.md    # Spec 模板
│   └── <feature-id>/       # 各功能的详细 spec
│       └── SPEC.md
├── api/                    # API 接口规范
│   └── API-TEMPLATE.yaml   # OpenAPI 3.0 模板
│   └── <feature-id>.yaml   # 各模块的 API 定义
├── plan/                   # 技术方案文档
│   └── <feature-id>/       # 方案设计、架构图等
└── reviews/                # Code Review 报告
    └── <feature-id>.md     # Review 记录
```

## 文档生命周期

每个功能从想法到上线，对应以下文档：

```
IDEA → PLAN → TEST-PLAN → CODE → REVIEW → DEPLOY-TEST → TEST-RUN → EVAL → DEPLOY-PROD
  │       │         │        │      │           │            │       │          │
  ▼       ▼         ▼        ▼      ▼           ▼            ▼       ▼          ▼
需求草稿 Spec  测试计划   代码   Review报告  部署记录    测试报告  评估报告  发布说明
```

## 文档命名约定

| 类型 | 格式 | 示例 |
|------|------|------|
| Spec | `specs/<feature-id>/SPEC.md` | `specs/feat-20260509-001/SPEC.md` |
| API | `api/<feature-id>.yaml` | `api/user-auth.yaml` |
| Plan | `plan/<feature-id>/DESIGN.md` | `plan/feat-20260509-001/DESIGN.md` |
| Review | `reviews/<feature-id>.md` | `reviews/user-auth-v1.2.md` |
| State Log | `state-log.md` | 追加式日志 |

## 快速开始

### 创建新功能 Spec

```bash
# 复制模板
cp docs/specs/SPEC-TEMPLATE.md docs/specs/<feature-id>/SPEC.md

# 填写内容后进入 REVIEWED 状态
```

### 创建新 API 规范

```bash
# 复制模板
cp docs/api/API-TEMPLATE.yaml docs/api/<feature>.yaml

# 填写并验证
npx swagger-cli validate docs/api/<feature>.yaml
```

## 文档状态流转

```
DRAFT → REVIEWED → APPROVED → IMPLEMENTING → DONE
  ↑                                    |
  └──────────── 变更回退 ←─────────────┘
```

## 与工作流的关联

- **PLAN 阶段**：产出 `specs/*/SPEC.md` 和 `plan/*/DESIGN.md`
- **TEST-PLAN 阶段**：产出测试用例骨架（嵌入 Spec）
- **REVIEW 阶段**：产出 `reviews/*.md`
- **EVAL 阶段**：汇总所有文档，生成评估报告