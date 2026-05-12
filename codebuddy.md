# CodeBuddy 编码原则

> 基于 Andrej Karpathy 的 4 条基本编码原则，适用于所有 AI 辅助代码写作场景。

---

## I. Karpathy's 4 Basic Rules (For Code Writing)

### Rule 1: Think Before Coding

**在编码之前先思考。**

- 明确陈述你的假设
- 对不确定的地方提问，而不是猜测
- 存在歧义时，提供多种解释
- 如果存在更简单的方法，指出它

```
❌ "Assume the user is logged in"
✅ "What is the authentication flow? Do we need to handle guest users?"
```

---

### Rule 2: Simplicity First

**简单性优先。**

- 只写解决问题所需的最小代码
- 不要写投机性功能（speculative features）
- 只使用一次的代码不要抽象
- 不要过度工程化

```
❌ // "Let's make this configurable for future use cases"
✅ // Just hardcode it for now, refactor when needed
```

---

### Rule 3: Surgical Changes

**精准修改，像外科手术一样。**

- 只触碰必须修改的地方
- 不要"顺便"优化无关的代码、注释或格式
- 不要修复没有坏的东西
- 保持与现有代码风格一致

```
❌ // While I'm here, let me clean up the formatting and add comments
✅ // Only modify the specific function/variable that needs changing
```

---

### Rule 4: Goal-Driven Execution

**目标驱动执行。**

- 定义成功标准，然后循环直到验证成功
- 不要告诉 AI 执行步骤，而是定义"什么是成功"
- 让 AI 自己迭代

```
❌ "Step 1: Create function X. Step 2: Add error handling. Step 3: Write tests."
✅ "The function should return [expected output] for [input]. It should fail gracefully for invalid input."
```

---

## 应用检查清单

在提交代码之前，自问：

| 原则 | 检查项 |
|------|--------|
| Think | 我是否清楚陈述了需求和假设？ |
| Think | 有没有对不确定的地方提问？ |
| Simple | 这是解决当前问题所需的最小代码吗？ |
| Simple | 有没有写当前不需要的功能？ |
| Surgical | 我是否只修改了必须修改的地方？ |
| Surgical | 有没有"顺便"改其他无关内容？ |
| Goal | 是否定义了明确的成功标准？ |
| Goal | 是否验证了代码达到预期效果？ |

---

## 与 WebHarness 的结合

这 4 条原则与 WebHarness 的设计理念高度一致：

- **Rule 1** → IDEA 阶段充分澄清需求
- **Rule 2** → TDD 驱动，只写让测试通过的代码
- **Rule 3** → 代码审查（Review）中检查改动边界
- **Rule 4** → EVAL 阶段验证质量门禁是否通过
