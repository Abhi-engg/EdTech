import crypto from "crypto";
import { auth } from "../auth/auth.js";
import env from "../config/env.js";
import { buildHeaders } from "../utils/http.js";

export const signInWithEmail = async (req) =>
  auth.api.signInEmail({
    body: {
      email: req.body.email,
      password: req.body.password,
      rememberMe: req.body.rememberMe,
    },
    headers: buildHeaders(req),
    asResponse: true,
  });

export const signOut = async (req) =>
  auth.api.signOut({
    headers: buildHeaders(req),
    asResponse: true,
  });

export const getSession = async (req) =>
  auth.api.getSession({
    headers: buildHeaders(req),
    asResponse: true,
  });

export const requestPasswordReset = async (req) =>
  auth.api.requestPasswordReset({
    body: {
      email: req.body.email,
      redirectTo: req.body.redirectTo || env.betterAuthFirstLoginUrl,
    },
    asResponse: true,
  });

export const resetPassword = async (req) =>
  auth.api.resetPassword({
    body: {
      token: req.body.token,
      newPassword: req.body.newPassword,
    },
    asResponse: true,
  });

export const completeFirstLogin = async (req) => {
  const headers = buildHeaders(req);

  await auth.api.changePassword({
    body: {
      currentPassword: req.body.currentPassword,
      newPassword: req.body.newPassword,
      revokeOtherSessions: true,
    },
    headers,
  });

  const updateBody = {
    firstLogin: false,
  };

  if (req.body.profilePhotoUrl) {
    updateBody.image = req.body.profilePhotoUrl;
  }

  return auth.api.updateUser({
    body: updateBody,
    headers,
    asResponse: true,
  });
};

export const inviteUser = async (req) => {
  const tempPassword = crypto.randomBytes(16).toString("base64url");

  await auth.api.signUpEmail({
    body: {
      email: req.body.email,
      password: tempPassword,
      name: req.body.name,
      role: req.body.role,
      institutionId: req.body.institutionId,
    },
  });

  return auth.api.requestPasswordReset({
    body: {
      email: req.body.email,
      redirectTo: req.body.redirectTo || env.betterAuthFirstLoginUrl,
    },
    asResponse: true,
  });
};
