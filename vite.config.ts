/// <reference types="vitest" />
import { defineConfig } from "vite";
import { plugin as elm } from "vite-plugin-elm";

const testExclude = process.env.TEST_E2E === "true" ? [] : ["tests-e2e/**/*"];

export default defineConfig({
  build: {
    outDir: "./dist/static",
    emptyOutDir: true,
  },
  plugins: [elm()],
  test: {
    exclude: testExclude,
  },
});
