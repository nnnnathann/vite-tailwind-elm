import express from "express";
import { createServer } from "../api.js";
import { readArgs } from "./cli.js";
import dotenv from "dotenv";

const args = readArgs();
const app = express();

if (args.envFile) {
  console.info(`Loading environment variables from ${args.envFile}`);
  dotenv.config({ path: args.envFile });
  console.log(process.env);
}

app.use("/api", createServer());

app.use(express.static(args.staticDir));

app.listen(args.port, () => {
  console.log(`listening on port ${args.port}`);
});
