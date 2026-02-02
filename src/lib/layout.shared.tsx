import type { LinkItemType } from "fumadocs-ui/layouts/docs";
import type { BaseLayoutProps } from "fumadocs-ui/layouts/shared";
import Image from "next/image";
import { ThemeToggle } from "@/components/theme-toggle";

export const title = "API";

export const logo = (
  <>
    {/* Use client-side theme detection so the logo updates with the theme, not the OS preference */}
      <span className="font-bold text-xl">
    Chorus
  </span>
  </>
);

export const linkItems: LinkItemType[] = [];

/**
 * Shared layout configurations
 *
 * you can configure layouts individually from:
 * Home Layout: app/(home)/layout.tsx
 * Docs Layout: app/docs/layout.tsx
 */
export function baseOptions(): BaseLayoutProps {
  return {
    nav: {
      title: (
        <>
          {logo}
        </>
      ),
      transparentMode: "top",
    },
    themeSwitch: {
      component: <ThemeToggle mode="light-dark-system" />,
    },
  };
}
