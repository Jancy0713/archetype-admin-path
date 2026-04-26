# AI视频商家端管理系统

基于 `refine + Vite + shadcn/ui + Tailwind CSS v4` 的工程初始化基座。

当前只落地以下内容：

- 工程骨架、主题 token、样式入口和项目规则文档
- 上传、导出、通知、关键操作审计的能力占位
- 简体中文默认文案基线与未来 i18n 扩展位

当前明确不包含以下内容：

- 真实业务模块页面
- 真实业务接口、contract 和后端联调
- 登录注册、租户、权限等基础模块实现

## 开发命令

```bash
pnpm dev
pnpm build
pnpm preview
```

## 目录约定

- `src/app/providers/*`：主题、通知、审计等基础 provider
- `src/theme/*`：theme token 与语义色映射
- `src/styles/*`：全局样式和 CSS 变量桥接
- `src/routes/*`：工程基座页与平台能力占位页
- `src/features/*`：上传、导出、通知、审计等平台能力占位
- `docs/project/project-conventions.md`：项目长期规则文件

## 后续推进

后续 PRD 应优先补齐账号认证、租户上下文、权限与平台基础组件需求，再进入具体业务模块。
