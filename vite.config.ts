/// <reference types="vitest" />
import { defineConfig } from "vite";
import { plugin as elm } from "vite-plugin-elm";

export default defineConfig({
  build: {
    outDir: "./dist/static",
    emptyOutDir: true,
  },
  plugins: [elm()],
});
