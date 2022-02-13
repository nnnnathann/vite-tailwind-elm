import { beforeAll, describe, expect, test } from "vitest";
import supertest from "supertest";
import { createServer } from "../../server/api.js";
import express from "express";

describe("/api", () => {
  const app = express();
  beforeAll(async () => {
    app.use("/api", createServer());
  });

  test("GET /theNumber", async () => {
    const response = await supertest(app).get("/api/theNumber");
    expect(response.status).toBe(200);
    expect(response.body).toEqual({ theNumber: 0 });
  });
  test("POST /theNumber", async () => {
    const response = await supertest(app)
      .post("/api/theNumber")
      .send({ theNumber: 42 })
      .set("Content-Type", "application/json");
    expect(response.statusCode).toBe(200);
    const newNumber = await supertest(app).get("/api/theNumber");
    expect(newNumber.body.theNumber).toBe(42);
  });
});
