export type NavigationItem = {
  label: string;
  href?: string;
  status?: "active" | "placeholder";
  note?: string;
};

export const zhCN = {
  appName: "AI视频商家端管理系统",
  appSlug: "merchant-ai-video-admin",
  shell: {
    subtitle: "工程初始化基座",
    description:
      "当前只落地工程骨架、主题 token、平台能力占位和单语言中文基线，业务模块与接口 contract 留待后续 PRD。",
  },
  navigation: {
    active: [
      {
        label: "工程基座",
        href: "/",
        status: "active",
      },
      {
        label: "平台能力占位",
        href: "/platform-capabilities",
        status: "active",
      },
    ] satisfies NavigationItem[],
    placeholders: [
      {
        label: "登录与认证",
        status: "placeholder",
        note: "待后续 PRD 定义账号模型、会话状态与接口边界",
      },
      {
        label: "租户上下文",
        status: "placeholder",
        note: "待后续 PRD 收敛租户切换、成员结构与默认工作区",
      },
      {
        label: "权限与访问控制",
        status: "placeholder",
        note: "待后续 PRD 定义角色矩阵、页面可见性与动作权限",
      },
      {
        label: "业务模块页面",
        status: "placeholder",
        note: "本轮禁止引入真实业务模块页面或演示数据流程",
      },
    ] satisfies NavigationItem[],
  },
  capabilityNotes: {
    upload: "仅保留前端上传选择、格式说明和状态反馈占位，不接真实存储接口。",
    export: "仅保留导出入口和本地文件生成示例，不接真实业务数据导出。",
    notifications: "仅保留 sonner 通知桥接与统一调用入口，不接消息中心与后端推送。",
    audit: "仅保留关键操作审计事件封装与内存态预览，不落审计存储。",
    i18n: "当前默认仅提供简体中文文案基线，不生成正式 i18n 包，仅保留未来扩展位。",
  },
} as const;
