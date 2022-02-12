import process from "process";
import { program } from "commander";

export interface Args {
  port: number;
  staticDir: string;
}

export function readArgs(): Args {
  program.option("-p, --port <port>", "listening port", parseInt);
  program.option(
    "-s, --static <static>",
    "directory from which to serve static file"
  );
  program.parse();
  const staticDir = program.opts().static || "dist/static";
  const port = program.opts().port || parseInt(process.env.PORT ?? "3000");
  return {
    port,
    staticDir,
  };
}
