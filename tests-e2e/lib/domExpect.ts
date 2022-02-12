import { Page } from "puppeteer";
import { expect } from "vitest";

export function expectContainsText(
  selector: string,
  expected: string
): (page: Page) => Promise<void> {
  return async (page) => {
    const text = await domGet(selector, "textContent")(page);
    expect(text).toContain(expected);
  };
}

export function expectText(
  selector: string,
  expected: string
): (page: Page) => Promise<void> {
  return async (page) => {
    const text = await domGet(selector, "textContent")(page);
    expect(text).toBe(expected);
  };
}

export function domGet<K extends keyof Element>(
  selector: string,
  key: K
): (page: Page) => Promise<Element[K]> {
  return async (page) => {
    const el = await page.waitForSelector(selector);
    return el.evaluate((e, key) => e[key], [key]) as Promise<Element[K]>;
  };
}
