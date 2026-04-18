# Archetype Admin 探索文档

这个目录用于沉淀项目在探索阶段的核心结论、执行规则和实际步骤。

为了避免文档越积越散，当前只保留 4 类主线文档。

## 阅读顺序

如果要快速理解当前项目，按下面顺序读：

1. [`docs/exploration/MVP_WORKFLOW.md`](/Users/wangwenjie/project/archetype-admin-path/docs/exploration/MVP_WORKFLOW.md)
2. [`docs/exploration/ARCHITECTURE_RULE.md`](/Users/wangwenjie/project/archetype-admin-path/docs/exploration/ARCHITECTURE_RULE.md)
3. [`docs/exploration/AI_RULE.md`](/Users/wangwenjie/project/archetype-admin-path/docs/exploration/AI_RULE.md)
4. [docs/exploration/steps](/Users/wangwenjie/project/archetype-admin-path/docs/exploration/steps)

## 文档分层

### 1. 工作流主文档

- [`docs/exploration/MVP_WORKFLOW.md`](/Users/wangwenjie/project/archetype-admin-path/docs/exploration/MVP_WORKFLOW.md)

用于定义当前 MVP 版本的完整流程，包括：

- 从接收需求开始到变更回流的整体步骤
- PRD 拆解前的反问补全机制
- contract 作为真相源的工作方式
- 脚本优先、AI 补位的原则

### 2. 结构规则

- [`docs/exploration/ARCHITECTURE_RULE.md`](/Users/wangwenjie/project/archetype-admin-path/docs/exploration/ARCHITECTURE_RULE.md)

用于定义目录结构、schema 组织方式、资源边界和演进方式。

### 3. AI 约束

- [`docs/exploration/AI_RULE.md`](/Users/wangwenjie/project/archetype-admin-path/docs/exploration/AI_RULE.md)

用于定义 AI 在本项目中的行为边界，尤其是：

- 什么时候必须遵循目录契约
- 什么时候要先改 schema / contract
- 什么时候应该优先走脚本，而不是让 AI 临场生成

### 4. 步骤记录

- [`docs/exploration/steps/01-foundation.md`](/Users/wangwenjie/project/archetype-admin-path/docs/exploration/steps/01-foundation.md)
- [`docs/exploration/steps/02-structure-and-golden-slice.md`](/Users/wangwenjie/project/archetype-admin-path/docs/exploration/steps/02-structure-and-golden-slice.md)

步骤记录只记录真实执行过的探索动作，不承担总规则说明职责。

## 当前状态

当前已经明确：

- 先做前后端分离版本的工作流 MVP
- 先固化流程、contract、脚本和规则，不急着进入具体业务开发
- schema 按资源拆分，不做无限膨胀的全局单文件
- 能脚本化的部分优先脚本化，避免 AI 每次从零空写

## 文档维护原则

- 新的全局性结论优先更新主文档，而不是新开很多平级文档
- 新的实际操作优先记到 `steps/`
- 只有在现有主文档无法承载时，才新增新的顶层规则文档
