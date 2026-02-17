const jwt = require('jsonwebtoken');

const optionalAuthMiddleware = (req, _res, next) => {
  const header = req.header('Authorization');
  const token = header?.replace('Bearer ', '');
  if (!token) {
    req.user = null;
    return next();
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
  } catch {
    req.user = null;
  }

  return next();
};

module.exports = optionalAuthMiddleware;
