import dotenv from "dotenv";

dotenv.config();

const env = {
  port: Number(process.env.PORT) || 3000,
  nodeEnv: process.env.NODE_ENV || "development",
  databaseUrl: process.env.DATABASE_URL,
};

if (!env.databaseUrl) {
  throw new Error("DATABASE_URL is required");
}

export default env;
