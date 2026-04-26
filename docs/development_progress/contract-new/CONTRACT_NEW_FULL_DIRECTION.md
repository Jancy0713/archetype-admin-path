# Contract New Full Direction

这份文档用于承接 `contract` 下一大版本的完整改造方向。

当前阶段先做一件事：

- 持续把用户这次对新版本的完整需求和架构想法收进同一份总文档

当前阶段明确不做的事：

- 不把内容拆成 `01 / 02 / 03` 这种功能编号文档
- 不提前细化“第一步改什么脚本、第二步改什么目录”的文件级实现方案
- 不提前写实现排期

当前允许同步维护一份阶段级实施计划，但它应始终从属于这份总方向文档。

## 当前总方向

当前新方向可以先压成下面这条主链：

```text
init -> prd -> contract_handoff -> contract -> openapi/swagger -> develop
```

也就是：

- `final_prd` 后显式增加 `05 Contract Handoff`
- 一份 PRD 拆成多个独立 contract flows
- 一个 contract flow 最终收口成一个独立 `swagger/openapi`
- 前端代码生成和后续返工切到 `develop`

## 新版主链定稿口径

本轮先把下面这条表达正式写死，作为 `contract-new` 后续所有文档的统一口径：

```text
init -> prd -> contract_handoff -> contract -> openapi/swagger -> develop
```

这里的定稿含义是：

1. `contract_handoff` 是 `final_prd` 之后的显式主链步骤，不再只是隐式收口动作。
2. 一份 `final_prd` 不再默认只通向一个笼统的 `contract`，而是先拆成多个独立 contract flows。
3. `contract` 的正式工作单位是单个 contract flow，不是整份 PRD 的总 contract。
4. 单个 contract flow 的正式终点不是旧式 `publish contract`，而是一个独立 `swagger/openapi`。
5. `develop` 才承接前端代码生成、实现试错和返工；新版主链不再写成 `contract -> generation`。

这意味着后续文档如果再出现下面这种默认表达，都应视为旧主链惯性，而不是新版定义：

```text
init -> prd -> contract -> generation
```

## 为什么要改

当前已经暴露出几个明确问题：

1. `generation` 并不适合作为用户可独立手工起步的正式阶段。
2. 如果后续要修改已有需求，真正自然的回入口不是 `generation`，而是 `contract`。
3. 现有链路虽然已经能从 `final_prd` 自动生成 contract handoff，但阶段定义上没有把这一步单独立出来，导致“一个 PRD 产出多个 contract”这件事不够清晰。
4. `contract` 现在虽然已经稳定到 publish，但正式终点还没有明确写死。
5. 前端代码生成和实现返工天然波动更大，不适合继续跟 `contract` 或当前 `generation` 混在同一阶段。
6. 当前 `contract` 里的 `freeze / publish` 设计过重、过早，把本来还属于实现前初稿阶段的内容，当成了需要强收口、强发布的正式终态，明显拖慢主链推进。
7. 从真实开发场景看，`final_prd -> contract -> swagger` 这一段本身不该做得这么重，因为它更像稳定合同推导，AI 可发挥空间并不大，不值得提前长出过多脚本、提示词和 lifecycle 包袱。

## 当前已明确的方向

### 1. `init -> prd`

这段不变，继续负责把需求想清楚，并产出稳定的 `final_prd`。

### 2. `prd-05 Contract Handoff`

这是 `final_prd` 后面的新显式步骤。

它的职责不是直接写 contract，而是：

- 把一份 `final_prd` 拆成多个独立 contract flows
- 生成 contract 层交接说明
- 给出它们的大致顺序
- 给出它们的依赖关系
- 明确当前先进入哪一个 contract flow

目标形态应接近：

```text
runs/<prd-run>/
  -> runs/YYYY-MM-DD-contract-1
  -> runs/YYYY-MM-DD-contract-2
  -> runs/YYYY-MM-DD-contract-3
```

在新版里，它的正式地位是：

- 它是 `prd` 与 `contract` 之间的显式阶段边界
- 它负责把“一个 PRD”转换成“多个可独立推进的 contract flows”
- 它不是 contract 的附属说明，而是 contract 正式开工前的主链接点
- 后续任何 AI 都不应再把 `final_prd` 直接理解成“马上进入单一 contract 阶段”

### 3. `contract`

`contract` 从这里开始应被视为独立正式阶段。

它不是“generation 上游附属物”，而是主链中的中枢阶段。

它应支持的正式认知包括：

- 可以从 `final_prd` handoff 进入
- 未来也应支持从已有 contract 回切做修改
- 每个 contract flow 都独立推进自己的 contract 生命周期
- 当前阶段应优先把它当成“实现前协议初稿”，而不是过早进入重型 freeze/publish 生命周期

它在新版里的阶段边界应正式理解为：

- 输入：单个 contract flow 的 handoff、范围、依赖、禁止假设项
- 责任：把该 flow 收口为可供实现消费的稳定 API 合同表达
- 输出：该 flow 对应的独立 `swagger/openapi`

也就是说，`contract` 的职责不是继续承包前端代码生成，也不是在实现前就做过重的发布治理。

### 4. `openapi/swagger`

这一步不是新的用户大阶段名字，而是 `contract` 的正式终点产物。

当前推荐写死的理解是：

- 一个 PRD 可以产出多个 contract
- 一个 contract flow 应产出一个独立 `swagger/openapi`
- `openapi/swagger` 是 `contract` 的正式终点，不是可有可无的附带材料

也就是说，`contract` 阶段不应结束在“只是 publish 了一份 contract”，而应继续收口到稳定 API 合同。

但这里的“稳定”也不等于在实现前就走完整重型定稿流程。

当前更合理的理解应是：

- `final_prd -> contract_handoff -> contract -> swagger` 先快速形成实现前协议
- 真正的最终稳定合同，应在后续 `develop` 完成并确认实现后再沉淀

### 5. `develop`

前端代码生成、实现试错和返工，从这里开始切到后续新阶段。

这样做的原因是：

- `contract -> openapi/swagger` 相对稳定
- 前端开发波动更大
- 前端实现更适合独立成一条允许试错和返工的流程
- 很多“这里要不要加一个选项、字段是否要调整”的真实决策，只有在 develop 过程中才会暴露

新版这里要刻意避免一个误读：

- `develop` 不是旧 `generation` 改个名字
- `develop` 也不是继续附着在 `contract` 内部的一组实现步骤
- 它是消费 `contract + openapi/swagger` 后，承接前端代码生成、实现验证和返工的后续阶段

## 新版推荐目录形态

第二步先把新版主链下各阶段的推荐目录形态写死。

这里的目标不是提前规定每个脚本怎么落盘，而是把“哪个阶段负责持有什么正式产物”固定下来。

### 1. `prd run` 在 `final_prd` 后的正式产物

当 `final_prd` 通过后，源 `prd run` 不应只停在一个抽象的“可以进 contract 了”状态。

它应显式长出一组 `Contract Handoff` 正式产物，推荐形态如下：

```text
runs/<prd-run-id>/
  prd/
    prd-04.final_prd.yaml
    rendered/
  contract_handoff/
    contract-handoff.index.yaml
    contract-handoff.md
    flows/
      01.<flow-id>.handoff.yaml
      01.<flow-id>.handoff.md
      02.<flow-id>.handoff.yaml
      02.<flow-id>.handoff.md
```

这里先把职责分开：

- `contract-handoff.index.yaml`
  - 负责表达本次一共拆出多少个 contract flows
  - 负责表达顺序、依赖、当前推荐入口和整体状态
- `contract-handoff.md`
  - 负责给人看的总览说明
  - 负责告诉用户当前应先进入哪个 flow
- `flows/*.handoff.yaml`
  - 负责作为单个 contract flow 的结构化正式输入
- `flows/*.handoff.md`
  - 负责作为单个 contract flow 的可读启动说明

也就是说，`Contract Handoff` 在目录层不是一句说明文字，而是一组明确的正式交接产物。

### 2. 多个 contract flows 的推荐 run 形态

新版推荐把“一个 PRD 拆出的多个 contract flows”理解为多个独立 contract runs，而不是继续把所有过程态永远堆在源 `prd run` 下面。

推荐形态如下：

```text
runs/<prd-run-id>/
  contract_handoff/
    ...

runs/YYYY-MM-DD-contract-<flow-id>/
  intake/
    contract-handoff.snapshot.yaml
    contract-handoff.snapshot.md
  contract/
    ...
```

这里要写死几个边界：

1. 源 `prd run` 持有的是“拆分结果与总览”。
2. 每个 `contract-<flow-id>` run 持有的是“单个 flow 的独立推进过程态与正式收口结果”。
3. 一个 flow 一个 run，才符合“一个 contract flow 最终收口一个独立 swagger/openapi”的阶段定义。
4. 并行与否由依赖关系决定，但即使并行，也仍然是多个独立 contract runs，而不是一个大 run 内的多个弱身份子目录。

### 3. 单个 contract flow 的推荐目录形态

单个 contract flow 的推荐 run 形态先压成下面这层最小结构：

```text
runs/YYYY-MM-DD-contract-<flow-id>/
  intake/
    contract-handoff.snapshot.yaml
    contract-handoff.snapshot.md
  contract/
    working/
      contract-draft.yaml
      rendered/
    release/
      openapi.yaml
      openapi.summary.md
      develop-handoff.md
```

这里要强调的不是文件名细节，而是目录分层意义：

- `intake/`
  - 存从 `prd` handoff 进入该 flow 的正式输入快照
- `contract/working/`
  - 存该 flow 的协议推导过程态
  - 这些内容属于 `contract` 内部工作态，不应直接被 `develop` 当正式输入消费
- `contract/release/`
  - 存该 flow 当前对下游正式暴露的稳定交付物
  - 其中核心就是独立 `openapi/swagger` 与对应说明材料

换句话说：

- `contract` 可以有过程态
- 但新版要求它最终收口成明确的 `release` 层
- `develop` 默认只吃这层正式释放出来的输入

## 第六步补充：contract run 必须标准化

前五步已经把主链跑通，但真实使用中又暴露出一个结构问题：

- `prd-05` 拆出的多个 contract flow run，不能只是 AI 临时创建的几个简单目录。

新版应继续坚持一个原则：

- `runs/` 下面每一个正式 run 都应该是独立、标准、可继续执行的工作区。

这意味着 `runs/YYYY-MM-DD-contract-<flow-id>/` 也要像 `init` / `prd` run 一样具备标准外壳：

```text
runs/YYYY-MM-DD-contract-<flow-id>/
  raw/
    request.md
    attachments/
  prompts/
    run-agent-prompt.md
  progress/
    workflow-progress.md
  intake/
    contract-handoff.snapshot.yaml
    contract-handoff.snapshot.md
  contract/
    working/
    release/
  rendered/
  archive/
```

这里的关键不是目录越多越好，而是职责清楚：

- `raw/` 保存本 run 的启动输入和上游快照。
- `prompts/run-agent-prompt.md` 是 human 新开上下文时可直接交给 AI 的启动提示词。
- `progress/` 保存这个 run 自己的进度，不靠别的 run 代管。
- `intake/` 保存 contract 机器流程要读取的 handoff 快照。
- `contract/working/` 保存过程态。
- `contract/release/` 保存后续 `develop` 能消费的正式包。

因此，`prd-05` 后续进入 contract flow 时，不应由 AI 自己手写三个文件夹。

正确口径应是：

1. 先由 `contract_handoff` 明确拆出哪些 flows、顺序和依赖。
2. 再由统一创建入口生成每个标准 contract run。
3. 再把每个 flow 的 handoff、final_prd 快照、依赖信息和启动提示词填入对应 run。

## 第六步补充：human 启动材料必须是提示词

`contract_handoff/flows/*.handoff.yaml` 是结构化输入，不是 human 友好的启动材料。

human 面前真正应该出现的是：

```text
runs/YYYY-MM-DD-contract-<flow-id>/prompts/run-agent-prompt.md
```

这个提示词应该能直接交给一个新上下文 AI 使用，里面必须讲清楚：

- 当前做第几批
- 这批是什么功能
- 工作区在哪里
- 上游 handoff 快照在哪里
- 前置依赖是否已满足
- 本轮应该产出什么
- 哪些 scope 不能自行扩展

如果当前上下文继续执行，也应该沿用同一份提示词，而不是让 AI 自己凭自然语言摘要继续猜。

## 第六步补充：prd-05 回报必须先讲下一步

`prd-05` 完成后的 human 回报不能先列一堆文件。

标准顺序应是：

1. 先告诉 human：如果没有异议，建议直接进入哪一批。
2. 再告诉 human：可以在当前上下文继续，也可以新开上下文使用哪份启动提示词。
3. 再逐条列出本次拆出的功能批次。
4. 最后才列关键文件。

表达方式也要固定：

- 不写“请确认是否按以上顺序执行”。
- 写“如果没有异议，建议直接进入第 1 批；如果批次名称、顺序或依赖关系不对，我们先修改 `contract_handoff`”。
- 不问“是否现在创建并初始化这些标准 contract run 工作区”。
- 不用 `batch-a -> batch-b` 这种链式表达替代逐条说明。

## `contract -> openapi/swagger` 的正式收口

第二步要明确的不是“openapi 怎么自动生成”，而是“什么叫一个 flow 已经正式收口”。

当前推荐最小规则如下：

1. 单个 flow 必须有一份独立 `openapi/swagger` 主文件。
2. 该主文件必须能被识别为该 flow 的正式 API 合同，而不是过程性草稿。
3. 与这份 `openapi/swagger` 一起暴露的，还应至少有：
   - 一份面向人阅读的摘要说明
   - 一份面向 `develop` 的 handoff 说明
4. `contract` 过程态中的分析草稿、review 中间态、讨论性笔记，不属于 `develop` 正式输入。

推荐把单个 flow 的正式终态理解成下面这个最小交付包：

```text
runs/YYYY-MM-DD-contract-<flow-id>/contract/release/
  openapi.yaml
  openapi.summary.md
  develop-handoff.md
```

这里的关键不是固定扩展名，而是固定语义：

- `openapi.yaml`
  - 是该 flow 的正式 API 合同
- `openapi.summary.md`
  - 是该合同的人类可读摘要
- `develop-handoff.md`
  - 是该合同进入 `develop` 时的交接说明

## `develop` 的正式输入边界

新版第二步必须把 `develop` 的正式输入写清楚。

当前推荐理解是：

`develop` 默认消费的不是整份 `final_prd`，也不是 `contract` 过程态目录，而是“单个 contract flow 已正式释放的交付包”。

推荐最小输入清单如下：

1. 该 flow 的 `openapi/swagger` 主文件
2. 该 flow 的 `openapi.summary.md`
3. 该 flow 的 `develop-handoff.md`
4. 必要时附带该 flow 的 handoff 快照，用于回看范围、依赖和禁止假设

也就是说，`develop` 的推荐入口形态应接近：

```text
develop input
  <- runs/YYYY-MM-DD-contract-<flow-id>/contract/release/openapi.yaml
  <- runs/YYYY-MM-DD-contract-<flow-id>/contract/release/openapi.summary.md
  <- runs/YYYY-MM-DD-contract-<flow-id>/contract/release/develop-handoff.md
  <- runs/YYYY-MM-DD-contract-<flow-id>/intake/contract-handoff.snapshot.yaml
```

这里要明确两条硬边界：

1. `develop` 不应默认直接消费 `contract/working/` 下的过程态文件。
2. `develop` 中暴露出来的实现问题，可以反向推动 `contract/swagger` 调整，但这属于第三步要继续定稿的“回改机制”，不是第二步现在就展开的规则。

## 第二步定稿结论

第二步先把下面四件事写死：

1. `final_prd` 通过后，源 `prd run` 应显式产出 `contract_handoff/` 目录，并包含总览索引、总览说明和 per-flow handoff 文件。
2. 一份 PRD 拆出的多个 contract flows，推荐各自进入独立 `runs/YYYY-MM-DD-contract-<flow-id>/`，而不是永远挤在源 run 里只有弱身份子目录。
3. 单个 contract flow 的正式终态，应以 `contract/release/` 形式暴露一个独立 `openapi/swagger` 交付包。
4. `develop` 默认只消费 `contract/release/` 暴露出来的正式输入，不直接消费 `contract` 过程态。

## 新版回改入口与重走规则

第三步要解决的是：

- 后续如果要修改需求，到底从哪一层回切
- 回切以后哪些阶段必须重走
- `develop` 完成后哪一层才算新的稳定基线

这里先把回改入口分成四层来理解：

### 1. 回到 `final_prd`

当变化已经影响整份需求边界、模块拆分逻辑、业务目标或跨 flow 的整体优先级时，应该回到 `final_prd`。

典型场景包括：

- 需求范围被整体增删
- 角色、资源、关键流程被重定义
- 原本的 flow 拆分方式已经不成立
- 多个 contract flows 的顺序和依赖关系需要整体重排

从这一层回切，意味着后面应重新进入：

```text
final_prd
-> contract_handoff
-> affected contract flows
-> openapi/swagger
-> develop
```

也就是说：

- 只要上游需求结构变了，就不能跳过 `contract_handoff`
- 因为 flows 的拆分、顺序和依赖本身都可能失效

### 2. 回到 `contract_handoff`

当 `final_prd` 仍成立，但 flow 划分、flow 顺序、flow 依赖或当前推荐入口需要调整时，应回到 `contract_handoff`。

典型场景包括：

- 原先一个 flow 需要拆成两个
- 原先两个 flows 需要合并
- 依赖关系改变，导致推荐执行顺序变化
- 某个 flow 的范围需要重分配给其它 flow

从这一层回切，意味着至少应重走：

```text
contract_handoff
-> affected contract flows
-> openapi/swagger
-> develop
```

这里的关键边界是：

- 不是所有修改都要打回 `final_prd`
- 但只要 flow 划分或依赖变了，就不能只在单个 contract flow 内偷偷修

### 3. 回到单个 contract flow

当 `final_prd` 与 `contract_handoff` 都仍成立，只是某个 flow 对应的 API 合同需要修改时，应只回到该 flow 的 `contract` 阶段。

典型场景包括：

- 字段设计需要调整
- 接口形态需要修改
- 某个 flow 的 `openapi/swagger` 需要补充或删减
- 实现中暴露出该 flow 自身的合同问题，但没有改动 flow 拆分与依赖

从这一层回切，最小重走路径应是：

```text
affected contract flow
-> openapi/swagger
-> affected develop work
```

如果某个被改动 flow 是其它 flows 的依赖，则还要继续判断：

- 下游 flow 是否只需要重新消费新的上游 `openapi/swagger`
- 还是下游 flow 自己的合同也必须重走

也就是说：

- 回到单个 flow 不等于永远只改一个 run
- 是否继续波及下游 flow，取决于依赖边界是否被打穿

### 4. 回到实现后稳定基线

当变更发生在“系统已经完成 develop，并形成被实现验证过的稳定版本”之后，默认不应回到旧的实现前合同草稿，而应从实现后稳定基线回切。

这里的含义是：

- 实现完成后，系统应已有一层“被实现验证过的正式真相源”
- 后续修改默认从这层真相源继续，而不是回到旧的 `contract working` 或过早冻结的初稿

## 多 flow 情况下的最小重走原则

第三步要再补一条纪律：

- 新版不能把回改重新做成“要么全部重来，要么局部硬改”的二元选择

当前推荐最小规则是：

1. 先判断变化影响的是“需求边界”“flow 划分”“单个 flow 合同”还是“实现后稳定基线”。
2. 再从对应层级开始重走，而不是默认回到最上游。
3. 如果某个 flow 被修改后打穿了依赖边界，则其下游依赖 flow 也应进入受影响集合。
4. 如果某个变化只影响单个 flow 的局部合同，不应强制所有 sibling flows 全部重走。

可以压成下面这条最小 replay 逻辑：

```text
change detected
-> identify re-entry layer
-> identify affected flows
-> replay only required downstream stages
```

这条纪律的目的，是继续守住：

- 一份 PRD 可以产出多个独立 flows
- 一个 flow 对应一个独立 `openapi/swagger`
- 回改时也不能把这些独立身份重新糊回一个大一统流程里

## 实现前协议与实现后稳定基线

第三步必须把这两层正式区分开：

### 1. 实现前协议层

这一层就是第二步已经定下来的：

```text
runs/YYYY-MM-DD-contract-<flow-id>/contract/release/
  openapi.yaml
  openapi.summary.md
  develop-handoff.md
```

它的定位是：

- 供 `develop` 使用的正式输入
- 已经比 `contract working` 稳定
- 但仍然属于“实现前协议收口”

这层不是最终稳定基线。

### 2. 实现后稳定基线层

当 `develop` 完成，并且该 flow 对应的实现已经验证通过后，系统应继续沉淀一层新的正式真相源。

当前推荐先把它理解成：

```text
baselines/<flow-id>/current/
  openapi.yaml
  openapi.summary.md
  implementation-settlement.md
  develop-verified-handoff.md
```

这里的关键不是目录名一定叫 `baselines/`，而是语义必须成立：

- 这层产物已经经过实现验证
- 它是后续修改默认应回切的稳定起点
- 它不再等同于实现前 `contract/release`

也就是说：

- `contract/release` 负责把协议交给 `develop`
- `baseline/current` 负责把“被实现验证过的稳定真相源”沉下来

### 3. 基线仍以 flow 为单位沉淀

第三步当前先不把基线强行聚合成整项目单一大包。

当前更合理的做法是：

- 先继续按 flow 维度沉淀稳定基线
- 必要时再补一层更高的聚合索引

原因很直接：

- 新版主链的核心单位本来就是独立 contract flow
- 如果太早把稳定基线重新收成整项目单一大包，很容易把第二步刚定下来的 flow 边界又冲掉

## 旧 `freeze / publish` 的新版定位

第三步需要把这件事彻底说清楚：

- 旧 `freeze / publish` 不再是新版 `contract` 阶段里的正式终点
- 但新版仍然需要一层“正式沉淀”语义

当前推荐的新定位是：

1. 实现前：
   - `contract/release` 只是“协议已收口，可交给 develop”
   - 它不等于最终稳定定稿
2. 实现后：
   - 真正承担“正式沉淀”职责的，是实现验证后的稳定基线沉淀动作
   - 也就是说，旧 `freeze / publish` 的概念层职责，被后移到实现后基线 settlement

换句话说：

- 新版不是完全不要“正式沉淀”
- 而是不再把它发生在实现前
- 真正等价于旧“发布正式版”的动作，应发生在 `develop` 完成并验证之后

这也是为什么旧 `freeze / publish` 不能原样继承：

1. 旧方案把正式定稿压得太靠前。
2. 新版要求先让 `contract -> openapi/swagger -> develop` 跑通真实实现反馈。
3. 只有实现反馈回来了，新的正式真相源才值得沉淀成稳定基线。

## 第三步定稿结论

第三步先把下面四件事写死：

1. 修改需求时，回切入口应按层判断：
   - 改整体验证范围，回到 `final_prd`
   - 改 flow 划分与依赖，回到 `contract_handoff`
   - 改单个 flow 合同，回到对应 `contract flow`
   - 改实现后稳定版本，默认从实现后稳定基线回切
2. 回切后只重走必要下游阶段，不默认全部重来；但一旦打穿依赖边界，受影响下游 flows 必须进入 replay 集合。
3. `develop` 完成后，新的正式真相源不再是实现前 `contract/release`，而是一层按 flow 维度沉淀的实现后稳定基线。
4. 旧 `freeze / publish` 在新版中的等价职责，被后移到“实现验证后的基线 settlement”，而不是继续放在实现前 `contract` 主链里。

## 新版迁移策略与实施顺序

第四步要解决的是：

- 旧资产怎么收口
- 真正开始改造时先做什么、后做什么
- 怎么验证实现没有把新版重新拉回旧主链

### 1. 旧资产分类原则

当前仓库里与 `contract-new` 相关的旧资产，先统一分成三类：

#### A. 历史实现参考

这类内容可以保留，但只能作为“老实现现实”参考，不能再被当作新版正式入口。

当前主要包括：

- `docs/contract/WORKFLOW_GUIDE.md` 中描述老 `contract` workflow、`freeze / publish`、published contract 与 generation bridge 的段落
- `docs/development_progress/generation/` 下围绕老 `generation` 主链推进的历史材料
- 旧 `scripts/contract/` 中仍服务老 lifecycle 的脚本入口说明

对这类资产的处理原则是：

- 可以保留
- 必须显式标注 legacy / historical context
- 不再允许它们反向定义 `contract-new` 的正式主链

#### B. 过渡期对照资产

这类内容在迁移期仍有价值，但只能用于“新旧映射”“对照验证”“过渡说明”。

当前主要包括：

- 现有 `docs/contract/examples/`
- 现有 `runs/` 或 examples 中可用于比对旧路径与新路径差异的样例
- 部分能帮助定位旧行为的 smoke 清单

对这类资产的处理原则是：

- 可以短期保留
- 但必须从“正式依据”降级为“对照样例”
- 一旦新版对应样例和入口落稳，就应继续迁出正式入口叙事

#### C. 必须被新版正式入口替换的资产

这类内容不能继续充当新版正式路径。

当前最关键的是：

- 任何默认把主链写成 `init -> prd -> contract -> generation` 的入口说明
- 任何默认把实现前 `freeze / publish` 当成 `contract` 正式终点的入口说明
- 任何默认让下游直接消费 `contract` 过程态或旧 generation nested run 路径的说明与脚本入口

这类资产的处理原则是：

- 不再补 patch 维持旧叙事
- 必须由新版入口文档、目录和脚本逐步替换

### 2. 正式实施顺序

第四步当前把真正开始改造时的顺序写死如下：

#### Phase I: 入口文档先行

先改所有会决定 AI 理解主链的总入口文档。

优先级应为：

1. `contract-new` 总方向与实施计划入口
2. `README` / `WORKFLOW_GUIDE` 这类会被后续 AI 首先读到的入口文档
3. 新旧边界说明与 legacy 标注

理由很直接：

- 如果入口文档没先改，后面脚本和目录再怎么动，新的上下文仍会按旧主链理解

#### Phase II: 正式目录与路径入口收口

入口文档稳定后，再改正式目录与路径入口。

优先级应为：

1. `final_prd -> contract_handoff` 的目录落点
2. 独立 `contract flow run` 的路径形态
3. `contract/release -> develop input` 的正式交接路径
4. `baseline` 层的正式沉淀路径

理由是：

- 先把正式路径收口，后续脚本才有稳定目标可追

#### Phase III: 脚本与入口适配

正式路径收口后，再改脚本。

优先级应为：

1. 入口生成类脚本
2. 路径解析类脚本
3. handoff / release / baseline 相关脚本
4. legacy 脚本的降级说明或停用处理

这里要强调：

- 不能先大改脚本，再回头猜它应该服务哪条主链

#### Phase IV: 样例、README、smoke 对齐

脚本入口稳定后，再统一对齐样例与 smoke。

优先级应为：

1. 正式样例路径
2. README 中的样例引用
3. smoke 的正式断言入口
4. 旧样例和旧 smoke 的降级或移除

#### Phase V: 清旧资产

最后才做旧资产清理。

包括：

- 清掉仍在冒充正式入口的旧说明
- 清掉仍在指向旧 nested generation 或旧 lifecycle 的正式引用
- 把剩余保留内容明确归档为 legacy / historical materials

### 3. 回归分层规则

第四步必须把回归分层写清楚，避免后续再次只靠一条大 smoke 硬扛。

当前推荐至少分成四层：

#### Layer 1: 文档入口回归

检查目标：

- 所有关键入口文档是否仍统一描述新主链
- 是否仍有关键入口把 `contract -> generation` 当默认主线
- 是否仍有关键入口把旧 `freeze / publish` 写成新版正式终点

这一层主要抓“叙事回流”。

#### Layer 2: 目录与路径回归

检查目标：

- `prd run` 是否按新版产出 `contract_handoff/`
- `contract flow` 是否按独立 run / release / baseline 分层
- `develop` 是否默认只指向正式 release 输入

这一层主要抓“路径回流”。

#### Layer 3: 入口脚本回归

检查目标：

- 入口脚本是否解析新版正式路径
- 是否仍有默认读取旧过程态或旧 nested generation 路径的入口
- baseline settlement 是否有明确入口

这一层主要抓“实现入口回流”。

#### Layer 4: 样例与 smoke 回归

检查目标：

- 正式样例是否已经站到新版结构上
- smoke 是否围绕新版主链断言，而不是继续围绕旧 lifecycle
- 旧 smoke 是否已降级为历史对照，而不是正式 gate

这一层主要抓“验证回流”。

### 4. Implementation Readiness Gate

第四步要再补一条：不是文档一写完就可以直接大规模改造。

当前推荐的“可进入实现”最小 gate 是：

1. 前三步和第四步的总方向文档已稳定，不再存在关键边界悬而未决。
2. 关键入口文档已经统一站到新主链上。
3. 旧资产已经完成“历史参考 / 过渡对照 / 必须替换”三类划分。
4. 实施顺序已经明确到：
   - 先改哪些入口文档
   - 再改哪些目录路径
   - 再改哪些脚本
   - 再改哪些样例与 smoke
5. 回归分层已经明确，后续实现不是盲改。

只有这些条件满足后，才应该说：

- `contract-new` 已经完成方向定稿
- 可以进入真正实现期迁移

## 第四步定稿结论

第四步先把下面四件事写死：

1. 旧 `contract` / `generation` 相关资产可以保留部分历史参考，但不能再充当新版正式入口；凡是继续定义旧主链的内容，都必须被降级或替换。
2. 真正开始实现时，必须先改入口文档，再改正式目录与路径入口，再改脚本，再改样例与 smoke，最后再清旧资产。
3. 回归至少要分成文档入口、目录路径、入口脚本、样例与 smoke 四层，避免再次只靠一条大 smoke 掩盖主链回流。
4. 只有当主链边界、旧资产分类、实施顺序和回归分层都已明确后，才允许进入实现期迁移。

## 对当前 freeze / publish 的新判断

当前新版本方向里，需要明确补一条：

- 现有 `contract` 中那套很重的 `review -> freeze -> publish` 生命周期，不应原样搬进新版本主链

原因很直接：

1. 当前 `contract` 更像实现前协议初稿，而不是最终交付完成态。
2. 很多字段、选项和结构，只有在真实 develop 过程中才知道是否要调整。
3. 如果每次发现实现问题都要求先回到旧式 `contract freeze/publish` 主链，会让整个系统过长、过重，而且明显偏离真实用户场景。

所以当前新方向更倾向于：

- 不在 `contract-new` 一开始就继承这套重型 freeze/publish 设计
- 先把 `final_prd -> contract_handoff -> contract -> swagger` 做轻、做直
- 等 develop 跑通后，再决定“最终稳定合同”应该如何沉淀

这里还要补一条更明确的边界：

- 旧 `freeze / publish` 可以继续作为老 `contract` 实现中的历史机制存在
- 但它不再构成 `contract-new` 主链的正式阶段定义
- 新版第一步只承认“`contract` 收口到独立 `swagger/openapi`”这条正式终线

换句话说：

- 现在的 `contract` 更接近“实现前协议稿”
- 真正的定稿，更应在实现完成后再确认

## 关于修改已有需求的回入口

基于上面的判断，后续如果需求做完再修改，更合理的做法应是：

- 不是回到一个过早 freeze 的旧 contract 初稿
- 而是回到“当前已经被实现验证过的稳定 contract / swagger 基线”再修改

这说明新版本后面还需要继续回答一个问题：

- develop 完成后，系统到底要把哪一层沉淀成新的正式基线

但这个问题应放在新版本整体方案继续讨论时解决，而不是继续沿用当前老版本那套过重的 freeze/publish。

## 当前已明确共识

到目前为止，这个新大版本已经明确的共识有：

1. `final_prd` 后面应显式增加 `05 Contract Handoff`
2. 一份 PRD 可以产出多个独立 contract flows
3. `Contract Handoff` 应给出顺序、依赖关系和 contract 层交接说明
4. 一个 contract flow 的正式终点应是一个独立 `swagger/openapi`
5. `contract` 应是独立正式阶段
6. 后续修改需求时，应优先从 `contract` 回切，而不是从 `generation` 回切
7. 前端代码生成应切到后续 `develop`
8. 现有 `contract` 的重型 `freeze / publish` 设计不应原样继承到新版本主链
9. `final_prd -> contract -> swagger` 应优先做轻、做直，不要一开始就往最复杂方案做
10. 真正的稳定定稿更应在 develop 完成后确认，而不是在实现前就把 contract 强行冻结
11. 这次改造要尽量不留历史包袱，必要时允许推翻旧内容、搬迁旧内容，而不是继续叠兼容层
12. 当前这次需求改动已经属于较大版本调整，等总方向定稿后，必须先把完整开发方案规划清楚，再开始逐步实现，避免再次偏离

## 本轮定稿结论

本轮先把下面四件事明确写死：

1. 新版主链最终定成：

```text
init -> prd -> contract_handoff -> contract -> openapi/swagger -> develop
```

2. `Contract Handoff` 在新版中是 `prd` 与 `contract` 之间的显式主链阶段，负责把一份 PRD 拆成多个独立 contract flows，并给出顺序、依赖和交接说明。
3. `contract` 的正式终点是“单个 contract flow 对应的独立 `swagger/openapi`”，不是旧式 `freeze/publish` 的发布动作。
4. 旧 `freeze / publish` 不再原样继承，因为新版当前关注的是“实现前协议快速收口”，而不是在实现前就把仍可能变动的协议初稿强行做成重型终态。

## 待继续补充

这份文档后面继续承接：

- 你接下来补充的完整需求
- 还没定稿的边界
- 还没定稿的目录形态
- 还没定稿的阶段职责
- 新版里 freeze / publish / 定稿基线到底如何收口
- develop 完成后哪些产物应回沉为新的正式真相源

## 当前边界

这份文档当前不做：

- 具体脚本怎么改
- 目录怎么一步步迁
- 哪一轮先做哪个文件
- `openapi.yaml` 如何自动生成
- `develop` 目录和脚本如何实现
- 新旧资产如何逐步迁移的分步骤执行计划

这些内容要等当前方案完全讨论定稿后，再拆成正式开发步骤。
