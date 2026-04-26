# Contract Reviewer Workflow

## reviewer 身份要求

1. reviewer 必须由独立 reviewer 子 agent 执行；这不是人工 review。
2. 主产物生成 agent 不得自己兼任 reviewer。
3. 如果 reviewer 发现自己就是主产物生成者，应停止并要求启动独立 reviewer 子 agent。

## reviewer 任务边界

1. 只审查，不重写主产物正文。
2. 优先识别阻塞 release 的 blocking issue。
3. 不擅自补全关键业务事实、字段语义、权限边界或依赖关系。
4. 不把“表达可以更好”伪装成 blocking issue。
5. 如果发现问题属于更上游步骤，应明确指出应回退到哪一步返工。
6. reviewer 的任务止于 release 前质量门禁，不负责定义 develop 或 baseline 的后续动作。

## reviewer 审查重点

至少应重点检查：

1. 是否与上游 `contract-handoff.snapshot` 一致。
2. 是否仍然在当前 flow 范围内。
3. 是否覆盖关键 consumer views。
4. 是否具备下游消费完整度。
5. 是否存在未确认事实被写成正式协议。
6. 是否存在共享定义冲突或依赖引用不清。

## reviewer 输出要求

当前阶段虽然还未正式定义 review YAML 模板，但 reviewer 输出至少应显式表达：

1. 发现了哪些问题
2. 哪些问题属于 blocking issue
3. 是否允许进入 release
4. 如果不允许，应回退到哪一步返工
5. 哪些问题只是非阻塞观察项

## 返工约定

1. 主 agent 只能根据 reviewer 结果返工，不得跳过 review 直接进入 release。
2. 如果问题属于边界不清，应回到 `scope_intake`。
3. 如果问题属于资源和引用结构不清，应回到 `domain_mapping`。
4. 如果问题只是正式协议表达缺项，可回到 `contract_spec`。
5. 超过 retry 上限后，如果仍有 blocking issue，应升级给人。
6. 例行的 flow 切换不属于 reviewer 的人类升级场景；只有真实边界冲突、关键事实缺失或职责外问题才升级给人。

## 当前统一倾向

与现有 `init / prd` 一致，当前 `contract` 也建议先沿用：

- 最大 retry = `2`
- reviewer 为硬门禁
- 阶段专项 checklist 与 reviewer 通用规则同时存在
