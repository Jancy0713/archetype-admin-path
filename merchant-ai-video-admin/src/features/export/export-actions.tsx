import { DownloadIcon } from "lucide-react";

import { useAuditLog } from "@/features/audit";
import { usePlatformNotification } from "@/features/notifications";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

import { downloadFoundationManifest } from "./export-manifest";

export function ExportActions() {
  const { notify } = usePlatformNotification();
  const { logEvent } = useAuditLog();

  const handleExport = () => {
    downloadFoundationManifest();
    notify({
      title: "导出能力占位已触发",
      description: "当前仅导出本地说明文件，用于验证入口、通知和审计桥接。",
      tone: "success",
    });
    logEvent({
      category: "export",
      action: "export.placeholder.downloaded",
      detail: "已导出本地 manifest 文件，未调用真实导出任务。",
      status: "triggered",
    });
  };

  return (
    <Card className="shadow-elevated-sm">
      <CardHeader>
        <CardTitle>导出入口占位</CardTitle>
        <CardDescription>
          统一导出入口已落位，后续 PRD 需补充业务对象、字段选择、异步任务和权限边界。
        </CardDescription>
      </CardHeader>
      <CardContent className="flex flex-wrap items-center gap-3">
        <Button type="button" onClick={handleExport}>
          <DownloadIcon className="mr-2 h-4 w-4" />
          导出工程基座清单
        </Button>
        <Button type="button" variant="outline" disabled>
          等待 PRD 定义真实导出 contract
        </Button>
      </CardContent>
    </Card>
  );
}
