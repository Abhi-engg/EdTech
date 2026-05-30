import dotenv from "dotenv";

dotenv.config();

const env = {
  port: Number(process.env.PORT) || 3000,
  nodeEnv: process.env.NODE_ENV || "development",
  databaseUrl: process.env.DATABASE_URL,
  betterAuthSecret: process.env.BETTER_AUTH_SECRET,
  betterAuthFirstLoginUrl: process.env.BETTER_AUTH_FIRST_LOGIN_URL,
};

if (!env.databaseUrl) {
  throw new Error("DATABASE_URL is required");
}

if (!env.betterAuthSecret) {
  throw new Error("BETTER_AUTH_SECRET is required");
}

export default env;
