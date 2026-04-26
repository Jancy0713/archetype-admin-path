type Field = {
  label: string;
  value: string;
};

type FieldGroupProps = {
  title: string;
  fields: Field[];
};

export function FieldGroup({ title, fields }: FieldGroupProps) {
  return (
    <div className="rounded-2xl border bg-card p-4 shadow-elevated-sm">
      <h3 className="text-sm font-medium text-foreground">{title}</h3>
      <div className="mt-4 grid gap-3 md:grid-cols-2">
        {fields.map((field) => (
          <div key={field.label} className="rounded-lg bg-surface p-3">
            <p className="text-xs text-muted-foreground">{field.label}</p>
            <p className="mt-1 text-sm font-medium text-foreground">{field.value}</p>
          </div>
        ))}
      </div>
    </div>
  );
}
