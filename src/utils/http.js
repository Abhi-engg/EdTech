export const buildHeaders = (req) => {
  const headers = new Headers();

  Object.entries(req.headers).forEach(([key, value]) => {
    if (Array.isArray(value)) {
      value.forEach((entry) => headers.append(key, entry));
    } else if (value) {
      headers.append(key, value);
    }
  });

  return headers;
};

export const sendAuthResponse = async (res, response) => {
  const setCookie = response.headers.getSetCookie?.();

  if (setCookie && setCookie.length > 0) {
    res.setHeader("Set-Cookie", setCookie);
  } else {
    const cookie = response.headers.get("set-cookie");
    if (cookie) {
      res.setHeader("Set-Cookie", cookie);
    }
  }

  const contentType = response.headers.get("content-type");
  if (contentType) {
    res.setHeader("Content-Type", contentType);
  }

  if (response.status === 204) {
    res.status(204).end();
    return;
  }

  const body = await response.json().catch(() => null);
  res.status(response.status).json(body ?? {});
};
