# Contract Reviewer 文档

这个目录用于定义 `contract` 流程中的 reviewer 角色、review 目标、检查重点和放行/阻塞原则。

当前阶段先不展开具体 review 模板字段，而是先把 reviewer 应该做什么、不能做什么、什么时候放行写清楚。

当前正式口径：

- review 通过后进入 `contract/release/`
- 文中若仍出现 `freeze`，一律按旧术语理解，不代表当前正式终点

## Reviewer 的职责

`contract reviewer` 的职责不是帮主产物继续写内容，而是独立判断：

- 当前 batch 的 `contract_spec` 是否符合上游 handoff
- 是否已经足够成为下游可消费的正式输入
- 是否仍然存在会让前端、后端、AI 或脚本继续猜的关键空洞
- 是否应该允许进入 release

换句话说：

- 主产物负责“写出来”
- reviewer 负责“判断能不能被信”

## Reviewer 不是做什么的

reviewer 不是：

- 主 agent 的另一个写作阶段
- 范围扩写阶段
- 新需求澄清入口
- 大规模重构 `contract_spec` 的执行者
- 把模糊内容“脑补完整”的兜底角色

如果 reviewer 发现：

- 范围不清
- 依赖不清
- consumer views 不清
- 引用关系不清

应要求返工，而不是替主产物自行补齐。

## Reviewer 的独立性要求

`contract reviewer` 应继承与 `prd reviewer` 类似的独立纪律。

最少应满足：

- reviewer 必须由独立 reviewer 子 agent 执行；human 只在异常升级时裁决，不是常规 reviewer
- 主 agent 不得自己兼任 reviewer
- reviewer 不是主产物作者
- reviewer 不能只信任主产物的自我描述
- reviewer 应以实际 artifact 为准进行判断
- reviewer 输出应真正决定是否允许 release

如果后续要正式脚本化，这一层也应像 `prd` 一样成为硬门禁，而不是形式步骤。

但 reviewer 的门禁只负责：

- `contract_spec` 能不能进入 `contract/release/`

不负责：

- 要不要让用户强制阅读当前 flow 全部产物
- develop 或 baseline 的后续规则

后两者都不属于 reviewer 放行标准。

## Reviewer 的材料组织原则

`contract reviewer` 也应尽量参考现有 `prd reviewer` 的组织方式。

更合理的形态应是：

- reviewer 通用说明
- 当前步骤或当前关口的专项 checklist
- review 产物模板

也就是说，reviewer 不应只靠一篇总说明工作，而应像现有 `prd` 一样保留“通用规则 + 阶段专项检查项”的结构。

## Reviewer 的核心检查目标

reviewer 应重点回答下面几个问题。

### 1. 是否与上游 handoff 一致

要检查：

- 是否仍然在当前 flow 范围内
- 是否覆盖了当前 flow 必需的 `contract_scope`
- 是否照顾了 `required_contract_views`
- 是否遵守了 `do_not_assume`

### 2. 是否具备消费完整度

要检查：

- 前端是否还能在关键 view 上继续猜数据结构
- 后端是否还能在关键资源和动作上继续猜边界
- AI / 脚本是否还能在类型、mock、引用关系上继续猜

如果“还需要大量补猜”才能往下走，则不应放行。

### 3. 是否存在边界漂移

要检查：

- 是否引入了不属于本批的新资源或动作
- 是否重新打开了上游已明确排除的范围
- 是否把别的 batch 的内容提前混入本批

### 4. 是否存在共享定义冲突

要检查：

- 是否错误重定义了前序 released contract 中已有的共享对象
- 是否应该引用却没有引用
- 是否引用了不稳定、未正式 release 的外部定义

### 5. 是否存在命名和语义漂移

要检查：

- 资源名是否前后不一致
- 字段语义是否前后矛盾
- 状态、枚举、权限术语是否漂移

## Reviewer 应重点关注的几类问题

### 1. P0 级问题

出现这些问题时，不应允许 freeze：

- 当前 `contract_spec` 明显超出 batch 范围
- 关键 consumer views 缺失，导致下游无法消费
- 关键资源/动作/状态/权限边界仍然模糊
- 依赖引用不清，无法判断应复用还是应新增
- 存在未确认事实被写成正式协议

### 2. P1 级问题

这些问题可能不一定阻塞，但通常需要修订：

- 命名不一致
- 局部结构重复
- 某些说明不够清晰
- 某些错误语义或校验语义表达不完整

### 3. 非阻塞观察项

这类问题可以记录，但不一定阻塞当前 freeze：

- 表达可读性不够好
- 某些渲染视图层说明未来还可增强
- 某些命名可以进一步优化

## Reviewer 的放行标准

只有当下面条件成立时，reviewer 才应允许进入 freeze：

1. 当前 `contract_spec` 与上游 handoff 一致
2. 当前 batch 的关键 consumer views 已具备可消费完整度
3. 没有未解决的 blocking issue
4. 没有越过当前 batch 边界
5. 共享定义与依赖引用关系清楚
6. 当前结果足够供后续 batch 或 generation 使用

## Reviewer 的阻塞标准

如果下面任一情况成立，应阻塞 freeze：

1. 当前 contract 仍需要下游大量补猜
2. 当前 contract 仍混入未确认需求
3. 当前 contract 缺少关键 view、关键资源或关键动作协议
4. 当前 contract 与上游 handoff 冲突
5. 当前 contract 的依赖关系不清，无法稳定引用

## 为什么需要专项 checklist

只做通用 review 不够。

`contract` 的不同关口理论上会有不同重点。

但 MVP 当前先把正式 reviewer gate 放在：

- `contract_spec`

`scope_intake` 和 `domain_mapping` 先通过规则 + 决策门禁推进，后续如果发现稳定性不足，再补成独立 reviewer gate。

因此当前先保留：

- reviewer 通用规则
- `contract_spec` 专项 checklist

## Reviewer 与 freeze 的关系

reviewer 不直接等于 freeze。

推荐关系是：

```text
contract_spec
-> review
-> pass
-> freeze
```

也就是说：

- reviewer 负责判断是否可放行
- freeze 负责在 review 通过后声明“当前版本正式可引用”

没有 review pass，不应进入 freeze。

## Reviewer 与返工的关系

如果 reviewer 发现问题，返工应尽量回到最合适的上游步骤，而不是在当前 review 结果里硬补一切。

例如：

- 如果是 batch 边界问题，应回到 `scope_intake`
- 如果是资源和引用结构不清，应回到 `domain_mapping`
- 如果只是正式协议表达缺项，可回到 `contract_spec`

这能避免 reviewer 变成隐藏的“第二作者”。

## 当前阶段先不展开的内容

这份文档当前先不展开：

- review YAML 的完整 schema 细化
- checklist 的完整 severity 体系
- 具体 severity 命名与结构
- 具体 review_complete 脚本行为

说明：

- `review.template.yaml` 与当前 checklist 骨架已经存在
- 这里指的是更完整的校验、分级和自动化行为仍待后续补齐

## 建议结合阅读

1. [Contract README](/Users/wangwenjie/project/archetype-admin-path/docs/contract/README.md)
2. [Contract Workflow Guide](/Users/wangwenjie/project/archetype-admin-path/docs/contract/WORKFLOW_GUIDE.md)
3. [Contract Structured Output Guide](/Users/wangwenjie/project/archetype-admin-path/docs/contract/STRUCTURED_OUTPUT_GUIDE.md)
4. [Contract 步骤说明](/Users/wangwenjie/project/archetype-admin-path/docs/contract/steps/README.md)
5. [Review Step](/Users/wangwenjie/project/archetype-admin-path/docs/contract/steps/review.md)
