import type { PropsWithChildren } from "react";

import { Button } from "@/components/ui/button";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";

type DetailDrawerProps = PropsWithChildren<{
  title: string;
  description: string;
  triggerLabel: string;
}>;

export function DetailDrawer({
  title,
  description,
  triggerLabel,
  children,
}: DetailDrawerProps) {
  return (
    <Sheet>
      <SheetTrigger asChild>
        <Button type="button" variant="outline">
          {triggerLabel}
        </Button>
      </SheetTrigger>
      <SheetContent side="right" className="w-full sm:max-w-xl">
        <SheetHeader className="space-y-2">
          <SheetTitle>{title}</SheetTitle>
          <SheetDescription>{description}</SheetDescription>
        </SheetHeader>
        <div className="mt-6 space-y-4 text-sm text-muted-foreground">{children}</div>
      </SheetContent>
    </Sheet>
  );
}
