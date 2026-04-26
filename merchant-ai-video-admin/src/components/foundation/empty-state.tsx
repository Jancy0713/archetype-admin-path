import type { ReactNode } from "react";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

type EmptyStateProps = {
  title: string;
  description: string;
  icon?: ReactNode;
};

export function EmptyState({ title, description, icon }: EmptyStateProps) {
  return (
    <Card className="border-dashed shadow-elevated-sm">
      <CardHeader className="space-y-3">
        {icon}
        <CardTitle>{title}</CardTitle>
      </CardHeader>
      <CardContent>
        <p className="text-sm text-muted-foreground">{description}</p>
      </CardContent>
    </Card>
  );
}
