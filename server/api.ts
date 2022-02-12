import express, { ErrorRequestHandler, Request, Response } from "express";
import { checkSchema, matchedData, validationResult } from "express-validator";

/**
 * Build your endpoints here
 */
export function createServer() {
  let theNumber = 0;
  const app = express();
  app.get("/theNumber", (req, res) => {
    res.send({ theNumber });
  });

  const theNumberPost = checkSchema({
    theNumber: {
      in: ["query", "body"],
      isInt: true,
      toInt: true,
    },
  });
  app.post("/theNumber", theNumberPost, (req: Request, res: Response) => {
    const result = validationResult(req);
    if (!result.isEmpty()) {
      return res.status(422).json({ errors: result.array() });
    }
    const data = matchedData(req);
    theNumber = data.theNumber;
    res.json(data);
  });
  app.use(errorHandler);
  return app;
}

const errorHandler: ErrorRequestHandler = (err, req, res) => {
  console.error(JSON.stringify(err.stack));
  const errors =
    process.env.APP_ENV !== "production"
      ? String(err.stack)
          .split("\n")
          .map((message) => ({ message }))
      : ["Internal Server Error"];
  res.status(500).send({ errors });
};
