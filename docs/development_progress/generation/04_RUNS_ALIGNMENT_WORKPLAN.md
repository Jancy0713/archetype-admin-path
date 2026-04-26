# Runs Alignment Workplan

这份文档用于指导 `04`：统一调整现有 `runs/`、examples、说明文档与 smoke，使其符合当前“一个 published contract = 一个独立 generation run”的正式入口。

## 本轮目标

把当前仓库里仍沿用错误 generation 入口的 `runs/`、examples、README、smoke 和脚本引用，统一调整为当前正式结构。

## 本轮应完成

### Phase 4A: Inventory And Mapping

目标：

- 列出哪些文件仍在暗示 `runs/<source-run>/generation/<contract_id>/` 或 `generation/entries/<contract_id>/`
- 产出旧路径到“独立 generation run”路径的映射

### Phase 4B: Runs And Example Realignment

目标：

- 把正式样例对齐到：
  - `runs/<source-run-id>/bridge/`
  - `runs/generation-<contract_id>/`
- 把旧源 run 内嵌 `generation/` 与 `generation-run/` 样例降级为历史样例

### Phase 4C: Docs And Smoke Cleanup

目标：

- 把 README、workflow guide、smoke 清单里仍残留的旧 generation 主路径口径一起清掉
- 明确“bridge 只准备多个 generation runs，不承载 generation 子目录”

### Phase 4D: Verification Prep

目标：

- 给 `05` 主链验证准备 run 级验证依据
- 明确哪些 smoke 应围绕独立 generation run 断言

## 完成标准

本轮结束时，应达到：

1. `runs/`、examples、README、smoke 的正式叙事已经收敛到独立 generation runs
2. 源 run 下不再保留正式 `generation/<contract_id>/` 结构
3. 下一轮可以直接开始 `05` 主链验证
