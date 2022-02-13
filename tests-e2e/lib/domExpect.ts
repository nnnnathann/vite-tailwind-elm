import { Page } from "playwright-chromium";
import { expect } from "vitest";

export function expectContainsText(
  selector: string,
  expected: string
): (page: Page) => Promise<void> {
  return async (page) => {
    const text = await page.$eval(selector, (el) => el.textContent);
    expect(text).toContain(expected);
  };
}

export function expectText(
  selector: string,
  expected: string
): (page: Page) => Promise<void> {
  return async (page) => {
    const text = await page.$eval(selector, (el) => el.textContent);
    expect(text).toBe(expected);
  };
}
