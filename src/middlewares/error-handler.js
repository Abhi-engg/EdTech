export const notFoundHandler = (req, res) => {
  res.status(404).json({ error: "Not Found" });
};

export const errorHandler = (error, req, res, next) => {
  console.error(error);
  res.status(500).json({ error: "Internal Server Error" });
};
