import express from "express";
import { createServer } from "../api.js";
import { readArgs } from "./cli.js";

const args = readArgs();
const app = express();

app.use("/api", createServer());

app.use(express.static(args.staticDir));

app.listen(args.port, () => {
  console.log(`listening on port ${args.port}`);
});
