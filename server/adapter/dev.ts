import express from "express";
import { createServer } from "../api.js";
import { readArgs } from "./cli.js";
import { createServer as createViteServer, loadEnv } from "vite";

async function createDevServer() {
  Object.assign(process.env, loadEnv("development", process.cwd()));
  const vite = await createViteServer({
    server: { middlewareMode: "html" },
  });
  const api = createServer();
  const app = express();
  app.use("/api", api);
  app.use(vite.middlewares);
  return app;
}

createDevServer().then((server) => {
  const args = readArgs();
  server.listen(args.port, () => {
    console.log(`listening on port ${args.port}`);
  });
});
