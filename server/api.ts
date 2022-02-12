import express, { NextFunction, Request, Response } from "express";
import { checkSchema, matchedData, validationResult } from "express-validator";

/**
 * Build your endpoints here
 */
export function createServer() {
  let theNumber = 0;
  let version = 1;
  const app = express();
  app.get("/theNumber", (req, res, next) => {
    res.send({ theNumber, version });
  });

  const theNumberPost = checkSchema({
    theNumber: {
      in: ["query", "body"],
      isInt: true,
      toInt: true,
    },
  });
  app.post(
    "/theNumber",
    theNumberPost,
    (req: Request, res: Response, next: NextFunction) => {
      const result = validationResult(req);
      if (!result.isEmpty()) {
        return res.status(422).json({ errors: result.array() });
      }
      const data = matchedData(req);
      res.json(data);
    }
  );
  return app;
}
