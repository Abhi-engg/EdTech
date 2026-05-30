import { findUsers, createUserRecord } from "../services/users.service.js";

export const listUsers = async (req, res, next) => {
  try {
    const users = await findUsers();
    res.json(users);
  } catch (error) {
    next(error);
  }
};

export const createUser = async (req, res, next) => {
  const { name, email } = req.body;

  if (!name || !email) {
    return res.status(400).json({ error: "name and email are required" });
  }

  try {
    const user = await createUserRecord({ name, email });
    res.status(201).json(user);
  } catch (error) {
    next(error);
  }
};
