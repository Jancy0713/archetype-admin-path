export const spacingTokens = {
  1: "4px",
  2: "8px",
  3: "12px",
  4: "16px",
  5: "24px",
  6: "32px",
  7: "48px",
  8: "64px",
} as const;

export const radiusTokens = {
  sm: "8px",
  md: "12px",
  lg: "16px",
} as const;

export const shadowTokens = {
  sm: "0 1px 2px rgba(15, 23, 42, 0.06), 0 8px 20px rgba(15, 23, 42, 0.04)",
  md: "0 12px 30px rgba(15, 23, 42, 0.10)",
  focus: "0 0 0 3px rgba(37, 99, 235, 0.16)",
} as const;

export const typographyTokens = {
  xs: {
    fontSize: "12px",
    lineHeight: "18px",
  },
  sm: {
    fontSize: "14px",
    lineHeight: "22px",
  },
  md: {
    fontSize: "16px",
    lineHeight: "24px",
  },
  lg: {
    fontSize: "20px",
    lineHeight: "28px",
  },
  xl: {
    fontSize: "24px",
    lineHeight: "32px",
  },
} as const;
