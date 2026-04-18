# Step 01 - 基础环境搭建（The Foundation）

## 日期

2026-04-15

## 目标

按探索方案先建立一个最小可运行的 Refine 底座，并验证 `Headless + 手动接入 shadcn/ui` 这条路径是否可行。

## 输入背景

来源于 [`docs/idea/AI-First 管理后台架构方案.md`](/Users/wangwenjie/project/archetype-admin-path/docs/idea/AI-First%20管理后台架构方案.md) 和 [`docs/idea/AI 管理后台开发 Harness 实践.md`](/Users/wangwenjie/project/archetype-admin-path/docs/idea/AI%20管理后台开发%20Harness%20实践.md)。

本次希望采用的初始原则：

- 不使用 Ant Design 这类重型 UI 库
- 基础框架选 Refine
- Data Provider 选 `REST API`
- Auth Provider 选 `Custom`
- UI 先走 `Headless`
- 再手动接入 `shadcn/ui`

## 执行结果

已完成一个可构建的实验工程：[`foundation-refine`](/Users/wangwenjie/project/archetype-admin-path/foundation-refine)。

当前结果：

- Refine 工程已生成
- 选择项已按预期落地为 `REST API + Custom Auth + Headless`
- Tailwind v4 已手动接入
- `@/*` import alias 已补齐
- `shadcn/ui` 已初始化
- 一组后台基础组件已加入
- `npm run build` 已通过

## 关键选择

脚手架实际选择如下：

- Project template：`Vite`
- Backend service：`REST API`
- UI Framework：`Headless`
- Example pages：`No`
- Authentication：`Custom`
- Package manager：`npm`

## 执行命令

### 1. 验证原始脚手架命令

原始参考命令：

```bash
npm create refine-project@latest -- --template tailwind
```

实际结果：

- 该命令在 2026-04-15 已不可用
- `create-refine-project` 返回 `404 Not Found`

### 2. 使用当前官方 CLI 创建项目

实际可用命令：

```bash
npm create refine-app@latest foundation-refine
```

### 3. 验证原始 shadcn 初始化命令

原始参考命令：

```bash
npx shadcn-ui@latest init
```

实际结果：

- `shadcn-ui` CLI 已废弃
- 当前官方入口为 `npx shadcn@latest init`

### 4. 解决 Headless 模板的前置缺失

因为 `Headless` 模板默认不包含 Tailwind 和 import alias，直接初始化 shadcn 会失败。

补充动作：

```bash
npm install -D tailwindcss @tailwindcss/vite
```

并手动修改：

- [`foundation-refine/tsconfig.json`](/Users/wangwenjie/project/archetype-admin-path/foundation-refine/tsconfig.json)
- [`foundation-refine/vite.config.ts`](/Users/wangwenjie/project/archetype-admin-path/foundation-refine/vite.config.ts)
- [`foundation-refine/src/index.tsx`](/Users/wangwenjie/project/archetype-admin-path/foundation-refine/src/index.tsx)
- [`foundation-refine/src/index.css`](/Users/wangwenjie/project/archetype-admin-path/foundation-refine/src/index.css)

### 5. 初始化 shadcn/ui

```bash
npx shadcn@latest init
```

实际说明：

- 组件库选择：`Radix`
- preset 选择：`Nova`
- `Custom` preset 在新版 CLI 中会跳转到网页，不适合这次“先完成本地底座”的目标

### 6. 添加首批组件

```bash
npx shadcn@latest add button input card table form label textarea select badge dialog sheet dropdown-menu skeleton
```

本次实际写入的核心组件文件包括：

- `button`
- `input`
- `card`
- `table`
- `label`
- `textarea`
- `select`
- `badge`
- `dialog`
- `sheet`
- `dropdown-menu`
- `skeleton`

说明：

- `button` 在初始化阶段已生成，所以二次添加时被跳过
- 后续若新增组件，必须在本文件底部追加“补充记录”

### 7. 构建验证

```bash
npm run build
```

结果：

- 构建通过
- Vite 产物已生成到 `dist/`

## 实际偏差

这一步和最初设想存在以下偏差：

1. Refine 官方脚手架命令已变更，不再是 `refine-project`
2. `Headless` 模板不等于“自带 Tailwind”，需要手动补 Tailwind 和 alias
3. shadcn 官方 CLI 已从 `shadcn-ui` 迁移到 `shadcn`
4. shadcn 新版 CLI 存在 preset 选择步骤，`Custom` 不是本地直接初始化路径

## 产出物

文档：

- [`docs/exploration/README.md`](/Users/wangwenjie/project/archetype-admin-path/docs/exploration/README.md)
- [`docs/exploration/EXPLORATION_RULE.md`](/Users/wangwenjie/project/archetype-admin-path/docs/exploration/EXPLORATION_RULE.md)
- [`docs/exploration/steps/01-foundation.md`](/Users/wangwenjie/project/archetype-admin-path/docs/exploration/steps/01-foundation.md)

代码与配置：

- [`foundation-refine`](/Users/wangwenjie/project/archetype-admin-path/foundation-refine)
- [`foundation-refine/components.json`](/Users/wangwenjie/project/archetype-admin-path/foundation-refine/components.json)
- [`foundation-refine/src/components/ui`](/Users/wangwenjie/project/archetype-admin-path/foundation-refine/src/components/ui)

## 验证

已完成：

- `npm run build`

验证结论：

- 当前工程可以成功构建
- `Headless + 手动接入 shadcn/ui` 路线成立

## 后续补充

下一步建议优先补以下内容：

1. 建一个最小后台壳子页，把 `Card / Table / Input / Button` 真正用起来
2. 给 `dataProvider` 和 `authProvider` 补环境变量、mock 或约束接口
3. 明确这套探索结果最终要沉淀为 repo 内规则、Codex skill，还是两者都保留

## 补充记录模板

如果后续在本步骤下继续加组件，直接追加下面这段：

```md
### 补充记录 - YYYY-MM-DD

- 新增命令：`npx shadcn@latest add ...`
- 新增组件：
- 触发原因：
- 影响文件：
- 验证结果：
```
