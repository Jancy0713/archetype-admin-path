import { Badge } from "@/components/ui/badge";

type StatusBadgeProps = {
  tone: "success" | "warning" | "info";
  children: string;
};

export function StatusBadge({ tone, children }: StatusBadgeProps) {
  if (tone === "success") {
    return <Badge className="bg-success/12 text-success hover:bg-success/12">{children}</Badge>;
  }

  if (tone === "warning") {
    return <Badge className="bg-warning/12 text-warning hover:bg-warning/12">{children}</Badge>;
  }

  return <Badge className="bg-accent-soft text-primary hover:bg-accent-soft">{children}</Badge>;
}
