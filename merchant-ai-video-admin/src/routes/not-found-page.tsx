import { CompassIcon } from "lucide-react";
import { useNavigate } from "react-router";

import { EmptyState } from "@/components/foundation";
import { Button } from "@/components/ui/button";

export function NotFoundPage() {
  const navigate = useNavigate();

  return (
    <div className="flex min-h-[60vh] items-center justify-center">
      <div className="max-w-xl space-y-4">
        <EmptyState
          title="当前页面不在初始化范围内"
          description="本轮只交付工程基座与平台能力占位。若需要具体业务模块，请进入后续 PRD 流程。"
          icon={<CompassIcon className="h-6 w-6 text-primary" />}
        />
        <div className="flex justify-center">
          <Button type="button" onClick={() => navigate("/")}>
            返回工程基座
          </Button>
        </div>
      </div>
    </div>
  );
}
