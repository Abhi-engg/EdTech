import express from "express";
import routes from "./routes/index.js";
import { notFoundHandler, errorHandler } from "./middlewares/error-handler.js";

const app = express();

app.use(express.json());
app.use(routes);
app.use(notFoundHandler);
app.use(errorHandler);

export default app;
