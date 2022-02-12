import { build } from "vite";
import dotenv from "dotenv";
import { readArgs } from "./cli.js";
import express from "express";

const args = readArgs();

export async function runTestServer() {
  dotenv.config({ path: args.envFile });
  await build({ build: { outDir: args.staticDir } });
  const app = express();
  app.use(express.static(args.staticDir));
  app.listen(args.port);
}

runTestServer();
