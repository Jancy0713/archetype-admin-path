import { BellIcon, FileTextIcon } from "lucide-react";

import {
  DataTable,
  DetailDrawer,
  FieldGroup,
  PageHeader,
  PageSection,
  StatusBadge,
  UploadDropzone,
} from "@/components/foundation";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useAuditLog } from "@/features/audit";
import { ExportActions } from "@/features/export";
import { usePlatformNotification } from "@/features/notifications";
import { zhCN } from "@/shared/copy/zh-cn";

export function PlatformCapabilitiesPage() {
  const { notify } = usePlatformNotification();
  const { events, logEvent } = useAuditLog();

  const triggerNotificationPlaceholder = () => {
    notify({
      title: "通知能力占位已触发",
      description: "当前仅桥接 sonner toast 与统一调用入口，消息中心和后端推送待后续 PRD。",
      tone: "success",
    });
    logEvent({
      category: "notifications",
      action: "notifications.placeholder.previewed",
      detail: "手动触发了一次通知占位预览。",
      status: "triggered",
    });
  };

  return (
    <div className="space-y-8">
      <PageHeader
        title="平台能力占位"
        description="上传、导出、通知和关键操作审计已经接入工程扩展位，但都停留在不依赖业务 contract 的基础层。"
        actions={<StatusBadge tone="warning">无业务接口</StatusBadge>}
      />

      <PageSection
        title="能力包概览"
        description="每个能力包都只有统一入口、组件骨架和文档说明，没有真实后端联调。"
        aside={
          <DetailDrawer
            title="i18n 与平台能力边界"
            description="当前默认简体中文单语言基线，不生成正式 i18n 包，仅保留未来扩展位。"
            triggerLabel="查看范围说明"
          >
            <FieldGroup
              title="当前策略"
              fields={[
                { label: "i18n", value: zhCN.capabilityNotes.i18n },
                { label: "upload", value: zhCN.capabilityNotes.upload },
                { label: "export", value: zhCN.capabilityNotes.export },
                { label: "notifications", value: zhCN.capabilityNotes.notifications },
                { label: "audit", value: zhCN.capabilityNotes.audit },
              ]}
            />
          </DetailDrawer>
        }
      >
        <Tabs defaultValue="upload" className="space-y-4">
          <TabsList className="grid w-full grid-cols-4 lg:w-auto">
            <TabsTrigger value="upload">上传</TabsTrigger>
            <TabsTrigger value="export">导出</TabsTrigger>
            <TabsTrigger value="notifications">通知</TabsTrigger>
            <TabsTrigger value="audit">审计</TabsTrigger>
          </TabsList>

          <TabsContent value="upload" className="space-y-4">
            <UploadDropzone />
          </TabsContent>

          <TabsContent value="export" className="space-y-4">
            <ExportActions />
          </TabsContent>

          <TabsContent value="notifications" className="space-y-4">
            <div className="rounded-2xl border bg-card p-6 shadow-elevated-sm">
              <div className="flex flex-col gap-3 lg:flex-row lg:items-center lg:justify-between">
                <div className="space-y-1">
                  <h3 className="text-lg font-semibold text-foreground">通知 provider 桥接</h3>
                  <p className="text-sm text-muted-foreground">
                    统一通知入口已落位，当前只负责触发 toast 和沉淀审计事件。
                  </p>
                </div>
                <Button type="button" onClick={triggerNotificationPlaceholder}>
                  <BellIcon className="mr-2 h-4 w-4" />
                  触发通知占位
                </Button>
              </div>
            </div>
          </TabsContent>

          <TabsContent value="audit" className="space-y-4">
            <div className="rounded-2xl border bg-card p-6 shadow-elevated-sm">
              <div className="flex items-center gap-2">
                <FileTextIcon className="h-4 w-4 text-primary" />
                <h3 className="text-lg font-semibold text-foreground">审计事件预览</h3>
              </div>
              <p className="mt-2 text-sm text-muted-foreground">
                当前仅保留内存态事件流和前端封装入口，不落数据库、不写审计检索接口。
              </p>
            </div>
          </TabsContent>
        </Tabs>
      </PageSection>

      <PageSection
        title="最近审计事件"
        description="展示本地会话中由能力占位触发的事件，验证关键操作审计扩展位已经固定。"
      >
        <DataTable
          columns={[
            { key: "category", title: "分类" },
            { key: "action", title: "事件" },
            {
              key: "status",
              title: "状态",
              render: (item) => (
                <StatusBadge tone={item.status === "triggered" ? "success" : "info"}>
                  {item.status === "triggered" ? "已触发" : "基座事件"}
                </StatusBadge>
              ),
            },
            { key: "detail", title: "说明" },
          ]}
          data={events}
        />
      </PageSection>
    </div>
  );
}
