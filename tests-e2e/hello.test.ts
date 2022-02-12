import { afterAll, beforeAll, describe, test } from "vitest";
import puppeteer from "puppeteer";
import type { Browser, Page } from "puppeteer";
import { expectContainsText } from "./lib/domExpect";
import { mockJsonPath, setUp } from "./lib/interceptXhr";

describe("basic", async () => {
  let browser: Browser;
  let page: Page;

  beforeAll(async () => {
    browser = await puppeteer.launch();
    page = await browser.newPage();
    page.setDefaultTimeout(2_000);
    await page.setRequestInterception(true);
  });

  afterAll(async () => {
    await browser.close();
  });

  test("should have the correct title", async () => {
    const theNumberMock = setUp([
      mockJsonPath("/api/theNumber", {
        theNumber: 42,
      }),
    ]);
    await theNumberMock(page);
    await page.goto("http://localhost:3000", { timeout: 5000 });
    const validate = expectContainsText("body", `Server SAYS: 42`);
    await validate(page);
  }, 5_000);
});
