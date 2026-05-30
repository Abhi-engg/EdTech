import { Router } from "express";
import {
  forgotPassword,
  firstLogin,
  invite,
  performPasswordReset,
  session,
  signIn,
  signOutUser,
} from "../controllers/auth.controller.js";

const router = Router();

router.post("/sign-in", signIn);
router.post("/sign-out", signOutUser);
router.get("/session", session);
router.post("/forgot-password", forgotPassword);
router.post("/reset-password", performPasswordReset);
router.post("/first-login", firstLogin);
router.post("/admin/invite", invite);

export default router;
