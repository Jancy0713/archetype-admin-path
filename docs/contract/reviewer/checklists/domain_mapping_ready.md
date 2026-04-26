# Reviewer Checklist: domain_mapping_ready

## 当前用途

这份清单当前用于 `domain_mapping` 的规则 + 决策门禁自检材料，不代表已经启用正式 reviewer gate。

## 必查项

1. 当前 `domain_mapping` 是否仍然在本 batch 范围内，没有越界到其他 batch。
2. 资源、动作、状态、权限和 consumer views 的结构骨架是否已经拉清。
3. 是否明确区分共享定义与本批新增定义。
4. 是否显式标出必须在 `contract_spec` 中固化的引用计划。
5. 是否遗漏关键跨模块依赖，导致后续 `contract_spec` 仍需重判边界。
6. 是否把字段级最终协议提前混写成 mapping 主体。

## 放行标准

只有当下面条件成立时，才允许进入 `contract_spec`：

1. 当前 batch 的资源和动作边界清楚。
2. 当前 batch 的 consumer views 基本清楚。
3. 共享定义与新增定义边界清楚。
4. 关键引用计划已被标记。
5. 没有把最终 spec 细节提前混写成 mapping 主体。

## 典型阻塞信号

以下情况通常应直接阻塞：

1. 资源和动作关系仍然模糊。
2. consumer views 只字带过，无法支撑正式 spec。
3. 该复用的共享定义被当成新增定义重写。
4. 跨模块依赖未标注，后续无法稳定引用。
