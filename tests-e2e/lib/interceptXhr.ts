import { Page, ResponseForRequest } from "puppeteer";

export type ResponseMock = (url: URL) => null | ResponseForRequest;

export function mockJsonPath(pathname: string, body: any): ResponseMock {
  return path(pathname, {
    status: 200,
    contentType: "application/json",
    headers: {},
    body: JSON.stringify(body),
  });
}

export function path(path: string, response: ResponseForRequest): ResponseMock {
  return (url) => (url.pathname === path ? response : null);
}

export function setUp(mocks: ResponseMock[]): (page: Page) => Promise<void> {
  return async (page) => {
    page.on("request", async (e) => {
      if (e.resourceType() === "xhr") {
        const url = new URL(e.url());
        for (const mock of mocks) {
          const mockResult = mock(url);
          if (mockResult !== null) {
            await e.respond(mockResult);
            return;
          }
        }
        console.error("[warning] request not intercepted: ", e.url());
        await e.respond({
          status: 501,
          contentType: "text/plain",
          body: "Not Implemented",
        });
        return;
      }
      await e.continue();
    });
  };
}
