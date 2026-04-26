import { UploadCloudIcon } from "lucide-react";
import { useDropzone } from "react-dropzone";

import { useAuditLog } from "@/features/audit";
import { usePlatformNotification } from "@/features/notifications";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

import { useUploadPlaceholder } from "./use-upload-placeholder";

export function UploadDropzone() {
  const { notify } = usePlatformNotification();
  const { logEvent } = useAuditLog();
  const { isPending, items, rejections, registerFiles, setRejections } =
    useUploadPlaceholder();

  const { getRootProps, getInputProps, open } = useDropzone({
    noClick: true,
    maxFiles: 5,
    accept: {
      "video/*": [],
      "image/*": [],
    },
    onDropAccepted: (files) => {
      registerFiles(files);
      notify({
        title: "上传能力占位已触发",
        description: "文件只在本地会话中登记，用于验证组件、通知和审计扩展位。",
        tone: "success",
      });
      logEvent({
        category: "upload",
        action: "upload.placeholder.queued",
        detail: `已登记 ${files.length} 个本地文件，但未调用真实上传接口。`,
        status: "triggered",
      });
    },
    onDropRejected: (nextRejections) => {
      setRejections(nextRejections);
      notify({
        title: "上传占位拒绝了文件",
        description: "当前仅接受图片与视频文件，且不接业务校验规则。",
        tone: "warning",
      });
      logEvent({
        category: "upload",
        action: "upload.placeholder.rejected",
        detail: `有 ${nextRejections.length} 个文件被占位规则拒绝。`,
        status: "triggered",
      });
    },
  });

  return (
    <Card className="border-dashed shadow-elevated-sm">
      <CardHeader>
        <CardTitle>UploadDropzone</CardTitle>
        <CardDescription>
          只校验前端文件选择、通知反馈和审计事件，不接存储、转码或业务对象。
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <div
          {...getRootProps()}
          className="rounded-lg border border-dashed border-border bg-surface-muted p-6"
        >
          <input {...getInputProps()} />
          <div className="flex flex-col gap-3 text-sm text-muted-foreground">
            <UploadCloudIcon className="h-8 w-8 text-primary" />
            <div className="space-y-1">
              <p className="font-medium text-foreground">拖拽图片或视频到这里</p>
              <p>支持多文件选择。当前只保留格式说明、状态反馈与后续 PRD 扩展位。</p>
            </div>
            <div className="flex flex-wrap gap-3">
              <Button type="button" onClick={open}>
                选择本地文件
              </Button>
              <Button type="button" variant="outline" disabled={isPending}>
                {isPending ? "登记中..." : "等待后续接入上传策略"}
              </Button>
            </div>
          </div>
        </div>

        <div className="grid gap-3 lg:grid-cols-2">
          <div className="rounded-lg border bg-card p-4">
            <p className="text-sm font-medium text-foreground">已登记文件</p>
            <div className="mt-3 space-y-2 text-sm text-muted-foreground">
              {items.length === 0 ? (
                <p>尚未选择文件。后续 PRD 需补充格式限制、大小规则、上传状态流转与后端 contract。</p>
              ) : (
                items.map((item) => (
                  <div
                    key={item.id}
                    className="flex items-center justify-between rounded-md border bg-surface px-3 py-2"
                  >
                    <span className="truncate">{item.name}</span>
                    <span>{item.sizeLabel}</span>
                  </div>
                ))
              )}
            </div>
          </div>

          <div className="rounded-lg border bg-card p-4">
            <p className="text-sm font-medium text-foreground">拒绝原因占位</p>
            <div className="mt-3 space-y-2 text-sm text-muted-foreground">
              {rejections.length === 0 ? (
                <p>当前没有拒绝记录。这里预留给后续 PRD 的上传校验文案与错误码映射。</p>
              ) : (
                rejections.map((rejection) => (
                  <div key={rejection.file.name} className="rounded-md border bg-surface px-3 py-2">
                    <p className="font-medium text-foreground">{rejection.file.name}</p>
                    <p>{rejection.errors.map((error) => error.message).join("；")}</p>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
