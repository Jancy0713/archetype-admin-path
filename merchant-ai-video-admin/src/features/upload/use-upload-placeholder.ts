import { useTransition } from "react";
import type { FileRejection } from "react-dropzone";
import { useState } from "react";

import type { UploadCandidate } from "./types";

function formatFileSize(size: number) {
  if (size < 1024) {
    return `${size} B`;
  }

  if (size < 1024 * 1024) {
    return `${(size / 1024).toFixed(1)} KB`;
  }

  return `${(size / (1024 * 1024)).toFixed(1)} MB`;
}

export function useUploadPlaceholder() {
  const [items, setItems] = useState<UploadCandidate[]>([]);
  const [rejections, setRejections] = useState<FileRejection[]>([]);
  const [isPending, startTransition] = useTransition();

  const registerFiles = (files: File[]) => {
    startTransition(() => {
      setItems((current) => [
        ...files.map((file) => ({
          id: crypto.randomUUID(),
          name: file.name,
          sizeLabel: formatFileSize(file.size),
          mimeType: file.type || "unknown",
        })),
        ...current,
      ]);
    });
  };

  return {
    isPending,
    items,
    rejections,
    registerFiles,
    setRejections,
  };
}
