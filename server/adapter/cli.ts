import process from "process";
import { program } from "commander";

export interface Args {
  port: number;
  staticDir: string;
  envFile?: string;
}

export function readArgs(): Args {
  program.option("-p, --port <port>", "listening port", parseInt);
  program.option("-e, --env-file <env-file>", "environment variables file");
  program.option(
    "-s, --static <static>",
    "directory from which to serve static file"
  );
  program.parse();
  const staticDir = program.opts().static || "dist/static";
  const port = program.opts().port || parseInt(process.env.PORT ?? "3000");
  const envFile = program.opts().envFile;
  return {
    port,
    staticDir,
    envFile,
  };
}
