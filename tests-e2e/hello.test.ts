import { afterAll, beforeAll, describe, test } from "vitest";
import { Browser, chromium, Page } from "playwright-chromium";
import { expectContainsText } from "./lib/domExpect.js";
import { mockJsonPath } from "./lib/interceptXhr.js";

describe("basic", async () => {
  let browser: Browser;
  let page: Page;

  beforeAll(async () => {
    browser = await chromium.launch();
    page = await browser.newPage();
    page.setDefaultTimeout(2_000);
  });

  afterAll(async () => {
    await browser.close();
  });

  test("should have the correct title", async () => {
    const afterResponded = mockJsonPath("/api/theNumber", {
      theNumber: 42,
    })(page);
    await page.goto("http://localhost:3000", { timeout: 5000 });
    const validate = expectContainsText("body", `Server SAYS: 42`);
    await afterResponded();
    await validate(page);
  }, 5_000);
});
