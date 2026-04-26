import type { ReactNode } from "react";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

type KpiCardProps = {
  label: string;
  value: string;
  hint: string;
  icon?: ReactNode;
};

export function KpiCard({ label, value, hint, icon }: KpiCardProps) {
  return (
    <Card className="shadow-elevated-sm">
      <CardHeader className="flex flex-row items-start justify-between space-y-0">
        <div className="space-y-1">
          <p className="text-sm text-muted-foreground">{label}</p>
          <CardTitle className="text-2xl font-semibold">{value}</CardTitle>
        </div>
        {icon}
      </CardHeader>
      <CardContent>
        <p className="text-sm text-muted-foreground">{hint}</p>
      </CardContent>
    </Card>
  );
}
