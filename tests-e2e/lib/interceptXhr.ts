import { Page, Response } from "playwright";

export type ResponseMock = (page: Page) => () => Promise<Response>;

export function mockJsonPath(pathname: string, body: unknown): ResponseMock {
  return (page) => {
    page.route(
      (url) => url.pathname === pathname,
      (route) => {
        route.fulfill({
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(body),
        });
      }
    );
    return () =>
      page.waitForResponse((r) => new URL(r.url()).pathname === pathname);
  };
}
