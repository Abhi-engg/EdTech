import {
  completeFirstLogin,
  getSession,
  inviteUser,
  requestPasswordReset,
  resetPassword,
  signInWithEmail,
  signOut,
} from "../services/auth.service.js";
import { sendAuthResponse } from "../utils/http.js";

const requireBodyFields = (res, fields, body) => {
  const missing = fields.filter((field) => !body?.[field]);
  if (missing.length > 0) {
    res.status(400).json({ error: `Missing fields: ${missing.join(", ")}` });
    return false;
  }
  return true;
};

export const signIn = async (req, res, next) => {
  if (!requireBodyFields(res, ["email", "password"], req.body)) {
    return;
  }

  try {
    const response = await signInWithEmail(req);
    await sendAuthResponse(res, response);
  } catch (error) {
    next(error);
  }
};

export const signOutUser = async (req, res, next) => {
  try {
    const response = await signOut(req);
    await sendAuthResponse(res, response);
  } catch (error) {
    next(error);
  }
};

export const session = async (req, res, next) => {
  try {
    const response = await getSession(req);
    await sendAuthResponse(res, response);
  } catch (error) {
    next(error);
  }
};

export const forgotPassword = async (req, res, next) => {
  if (!requireBodyFields(res, ["email"], req.body)) {
    return;
  }

  try {
    const response = await requestPasswordReset(req);
    await sendAuthResponse(res, response);
  } catch (error) {
    next(error);
  }
};

export const performPasswordReset = async (req, res, next) => {
  if (!requireBodyFields(res, ["token", "newPassword"], req.body)) {
    return;
  }

  try {
    const response = await resetPassword(req);
    await sendAuthResponse(res, response);
  } catch (error) {
    next(error);
  }
};

export const firstLogin = async (req, res, next) => {
  if (!requireBodyFields(res, ["currentPassword", "newPassword"], req.body)) {
    return;
  }

  try {
    const response = await completeFirstLogin(req);
    await sendAuthResponse(res, response);
  } catch (error) {
    next(error);
  }
};

export const invite = async (req, res, next) => {
  if (!requireBodyFields(res, ["email", "name", "role"], req.body)) {
    return;
  }

  const allowedRoles = new Set([
    "super_admin",
    "institution_admin",
    "hod",
    "teacher",
    "student",
  ]);

  if (!allowedRoles.has(req.body.role)) {
    res.status(400).json({ error: "Invalid role" });
    return;
  }

  try {
    const response = await inviteUser(req);
    await sendAuthResponse(res, response);
  } catch (error) {
    next(error);
  }
};
