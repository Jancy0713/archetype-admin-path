import { semanticColors } from "./semantic-colors";
import {
  radiusTokens,
  shadowTokens,
  spacingTokens,
  typographyTokens,
} from "./tokens";

export const projectTheme = {
  name: "merchant-ai-video-admin-foundation",
  mode: "light",
  style: "flat-minimal-ai-native",
  spacing: spacingTokens,
  radius: radiusTokens,
  shadow: shadowTokens,
  typography: typographyTokens,
  colors: semanticColors,
} as const;

export type ProjectTheme = typeof projectTheme;

export * from "./semantic-colors";
export * from "./tokens";
