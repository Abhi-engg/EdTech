import http from "http";
import app from "./app.js";
import env from "./config/env.js";
import prisma from "./db/prisma.js";

const server = http.createServer(app);

server.listen(env.port, () => {
  console.log(`Server running on http://localhost:${env.port}`);
});

const shutdown = async () => {
  await prisma.$disconnect();
  server.close(() => process.exit(0));
};

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);
