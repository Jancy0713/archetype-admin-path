import { ArrowRightIcon, BlocksIcon, PaletteIcon, ShieldCheckIcon } from "lucide-react";
import { useNavigate } from "react-router";

import {
  EmptyState,
  FieldGroup,
  FilterBar,
  KpiCard,
  PageHeader,
  PageSection,
  StatusBadge,
} from "@/components/foundation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { projectTheme } from "@/theme";
import { zhCN } from "@/shared/copy/zh-cn";

export function FoundationOverviewPage() {
  const navigate = useNavigate();

  return (
    <div className="space-y-8">
      <PageHeader
        title={zhCN.appName}
        description={zhCN.shell.description}
        actions={
          <>
            <Button type="button" onClick={() => navigate("/platform-capabilities")}>
              查看平台能力占位
              <ArrowRightIcon className="ml-2 h-4 w-4" />
            </Button>
            <StatusBadge tone="info">默认浅色主题</StatusBadge>
          </>
        }
      >
        <div className="grid gap-4 lg:grid-cols-3">
          <KpiCard
            label="主题与 Token"
            value="11 项语义色 + 8 级间距"
            hint="design_seed 的 spacing、radius、shadow、typography 与语义色角色已落到代码层。"
            icon={<PaletteIcon className="h-5 w-5 text-primary" />}
          />
          <KpiCard
            label="平台默认能力"
            value="4 个能力包"
            hint="upload、export、notifications、audit 已接入占位层与统一 provider。"
            icon={<BlocksIcon className="h-5 w-5 text-primary" />}
          />
          <KpiCard
            label="后续 PRD 边界"
            value="未接业务 contract"
            hint="登录注册、租户、权限和真实业务模块仍保留给后续 PRD。"
            icon={<ShieldCheckIcon className="h-5 w-5 text-primary" />}
          />
        </div>
      </PageHeader>

      <PageSection
        title="页面模式基线"
        description="用工程层容器固定页面节奏，但不提前实现真实业务页面。"
      >
        <FilterBar>
          <Input value="关键字 / 任务名 / 素材名（占位）" readOnly />
          <Input value="状态筛选、租户筛选、时间筛选待 PRD" readOnly />
          <Textarea
            value="当前只保留 FilterBar、表单分区和中等信息密度的布局基线。"
            readOnly
            className="min-h-[92px]"
          />
        </FilterBar>
      </PageSection>

      <PageSection
        title="工程固定规则"
        description="长期规则文件已经从 run 产物落位到项目目录，供后续 PRD / 开发 / review 统一读取。"
      >
        <div className="grid gap-4 lg:grid-cols-2">
          <FieldGroup
            title="主题策略"
            fields={[
              { label: "风格方向", value: projectTheme.style },
              { label: "默认模式", value: "浅色主题" },
              { label: "信息密度", value: "中等信息密度" },
              { label: "导航骨架", value: "左侧主导航 + 顶部上下文区 + 页面内容容器" },
            ]}
          />
          <FieldGroup
            title="平台边界"
            fields={[
              { label: "上传", value: zhCN.capabilityNotes.upload },
              { label: "导出", value: zhCN.capabilityNotes.export },
              { label: "通知", value: zhCN.capabilityNotes.notifications },
              { label: "审计", value: zhCN.capabilityNotes.audit },
            ]}
          />
        </div>
      </PageSection>

      <PageSection
        title="后续 PRD 必补边界"
        description="这些能力在本轮只保留扩展位，不提前写假接口、假业务流程或演示数据。"
      >
        <div className="grid gap-4 lg:grid-cols-2">
          <EmptyState
            title="业务模块未落地"
            description="工作台、生成任务、素材、合规、账户等模块只停留在导航与规则层，未创建真实页面与流程。"
          />
          <EmptyState
            title="账号与权限未实现"
            description="登录方式、租户模型、RBAC、成员角色和访问控制留待后续 PRD 与 contract 阶段定义。"
          />
        </div>
      </PageSection>
    </div>
  );
}
