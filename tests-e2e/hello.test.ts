import { afterAll, beforeAll, describe, test } from "vitest";
import puppeteer from "puppeteer";
import type { Browser, Page } from "puppeteer";
import { expectText } from "./lib/domExpect";

describe("basic", async () => {
  let browser: Browser;
  let page: Page;

  beforeAll(async () => {
    browser = await puppeteer.launch();
    page = await browser.newPage();
    page.setDefaultTimeout(2_000);
    await page.setRequestInterception(true);
    page.on("request", async (e) => {
      if (e.resourceType() === "xhr") {
        console.error("[warning] request not intercepted: ", e.url());
        e.respond({
          status: 501,
          contentType: "text/plain",
          body: "Not Implemented",
        });
        return;
      }
      await e.continue();
    });
  });

  afterAll(async () => {
    await browser.close();
  });

  test("should have the correct title", async () => {
    await page.goto("http://localhost:3000", { timeout: 5000 });
    await expectText("h1", "New Application")(page);
  }, 5_000);
});
