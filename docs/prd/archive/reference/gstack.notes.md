# gstack 阅读摘要

## 来源

- 官网: [gstack.lol](https://gstack.lol/)
- GitHub: [garrytan/gstack](https://github.com/garrytan/gstack)

## 我们关注到的内容

gstack 的核心表达很明确：

- 它不是一堆 prompt
- 而是一套 ordered workflow

官网把整个流程概括为：

- Think
- Plan
- Build
- Review
- Test
- Ship
- Reflect

其中最值得我们关注的是前两步。

## 和我们当前问题最相关的点

### 1. `/office-hours` 非常像我们要做的“需求补充提问”

gstack 明确写到：

- `/office-hours` 会把 feature request 变成更清晰的问题
- 会 sharpen the wedge
- 会写出后续流程可继承的 brief

这和我们当前要设计的第一步几乎同类。

对我们的直接启发是：

- 用户给出需求后，不应该直接写 PRD
- 应该先有一个“问题澄清与聚焦”步骤
- 这一步的输出应是 brief，而不是最终实现

### 2. 它强调有序继承，而不是 blank prompt

gstack 反复强调：

- 不要信任 blank prompt
- 每一步都应该继承上一步的结果

这对我们当前的工作流设计非常关键。

因为我们的目标也是：

- 需求补问 -> PRD 拆解 -> contract -> 生成

如果每一步都重新从自然语言开始，AI 会不断漂移。

### 3. 先压 scope，再谈实现

从 `/office-hours` 和 `/plan-*` 的定位可以看出：

- 它先做问题重构
- 再做 scope 和 plan 审查
- 不是一开始就开始 build

这和我们现在决定“先不急着做具体开发”是同方向的。

## 对我们流程的启发

gstack 对我们最重要的启发有 3 个：

1. 把“需求补充提问”设计成正式入口步骤
2. 让这一步产出一个后续环节可继承的 brief
3. 后续步骤都应消费上一层产物，而不是重新发明上下文

## 当前结论

在“拆解 PRD”的第一个子步骤上，gstack 是当前最值得直接借鉴的参考之一。

我们不需要照搬它的整套命令，但可以借它的核心思路：

- 先重构问题
- 再锁定计划
- 不让实现直接接触原始、含混的需求输入
