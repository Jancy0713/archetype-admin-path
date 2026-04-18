# CCPM 阅读摘要

## 来源

- GitHub: [automazeio/ccpm](https://github.com/automazeio/ccpm)

## 我们关注到的内容

CCPM 的核心链路是：

- PRD Creation
- Epic Planning
- Task Decomposition
- GitHub Sync
- Parallel Execution

它强调的核心原则之一是：

- No Vibe Coding
- 每一行代码都应该能追溯到 specification

## 和我们当前问题最相关的点

### 1. 它明确把 guided brainstorming 放在最前面

CCPM 在 workflow phases 中提到：

- 在写 PRD 之前，会先问 problem、users、success criteria、constraints、out of scope

这和我们当前要补的“需求补充提问”高度一致。

也就是说：

- PRD 不是直接写出来的
- PRD 应该先经过一轮 guided brainstorming

### 2. 它把 PRD 视为后续一切的源头

CCPM 的链路很完整：

- PRD -> Epic -> Task -> Issue -> Code

对我们的启发是：

- 我们后面虽然不是完全走 GitHub Issue 驱动
- 但也应该让 PRD 拆解结果继续进入 contract，而不是停留在文档层

### 3. 它很重视确定性操作脚本

CCPM 明确提到：

- 某些跟踪操作是 bash scripts
- 这样更快、更一致、没有额外 LLM 开销

这和我们当前“能脚本化就尽量不要让 AI 空写”的原则非常一致。

## 对我们流程的启发

CCPM 对我们最直接的帮助有 3 个：

1. “提问后成文”的顺序是对的
2. 文档要继续进入后续分解和生成，而不是停留在文档本身
3. 确定性动作应该交给脚本

## 当前结论

如果说 gstack 更像“产品问题重构入口”，那 CCPM 更像“从 PRD 继续往后走的完整流水线参考”。

对我们当前这一步来说，最该吸收的是：

- guided brainstorming 的问题域
- spec-driven 的链路意识
- script-first 的执行偏好
