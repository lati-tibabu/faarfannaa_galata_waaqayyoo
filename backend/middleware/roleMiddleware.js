const roleMiddleware = (role, options = {}) => {
  const { allowAdmin = true } = options;

  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required.' });
    }
    const hasRole = req.user.role === role;
    const hasAdminOverride = allowAdmin && req.user.role === 'admin';

    if (!hasRole && !hasAdminOverride) {
      return res.status(403).json({ error: 'Access denied. Insufficient permissions.' });
    }
    next();
  };
};

module.exports = roleMiddleware;
