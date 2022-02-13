import "./tailwind.css";
import { Elm } from "./Main.elm";
import { getCLS, getFID, getLCP } from "web-vitals";

Elm.Main.init({
  flags: {
    appUrl: import.meta.env.BASE_URL,
    mode: import.meta.env.MODE,
    // To add an environment variable:
    // add to .env.development
    // add to Env.elm
    // add to index.d.ts
    myApiUrl: import.meta.env.VITE_MY_API_URL,
  },
});

if (import.meta.env.DEV) {
  console.log("welcome to vite-tailwind-elm!");
}

if (import.meta.env.ANALYTICS_URL) {
  const analytics = sendToAnalytics(import.meta.env.ANALYTICS_URL as string);
  getCLS(analytics);
  getFID(analytics);
  getLCP(analytics);
}

function sendToAnalytics(url: string): (metric: unknown) => void {
  return (metric) => {
    // Replace with whatever serialization method you prefer.
    // Note: JSON.stringify will likely include more data than you need.
    const body = JSON.stringify(metric);

    // Use `navigator.sendBeacon()` if available, falling back to `fetch()`.
    (navigator.sendBeacon && navigator.sendBeacon(url, body)) ||
      fetch(url, { body, method: "POST", keepalive: true });
  };
}
