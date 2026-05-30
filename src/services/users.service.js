import prisma from "../db/prisma.js";

export const findUsers = () =>
  prisma.user.findMany({
    orderBy: { createdAt: "desc" },
  });

export const createUserRecord = ({ name, email }) =>
  prisma.user.create({
    data: { name, email },
  });
