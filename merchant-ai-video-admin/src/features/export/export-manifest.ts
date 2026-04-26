import { saveAs } from "file-saver";

const foundationManifest = [
  "# AI视频商家端管理系统 - 工程基座导出清单",
  "",
  "- 当前导出仅验证前端文件生成与下载入口。",
  "- 未接真实业务数据、筛选参数、审计归档或权限校验。",
  "- 后续 PRD 需补齐导出对象、字段、文件格式和异步任务策略。",
].join("\n");

export function downloadFoundationManifest() {
  const blob = new Blob([foundationManifest], {
    type: "text/plain;charset=utf-8",
  });

  saveAs(blob, "foundation-export-manifest.txt");
}
