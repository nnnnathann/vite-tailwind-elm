import "./tailwind.css";

import { Elm } from "./Main.elm";

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

console.log("welcome to vite-tailwind-elm!");
